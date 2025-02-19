# Populate the database¶
Run the next script to fetch a sqlite DB we've prepared for this tutorial and update it to look like it's current. The details are unimportant.

```python
import os
import shutil
import sqlite3

import pandas as pd
import requests

db_url = "https://storage.googleapis.com/benchmarks-artifacts/travel-db/travel2.sqlite"
local_file = "travel2.sqlite"
# The backup lets us restart for each tutorial section
backup_file = "travel2.backup.sqlite"
overwrite = False
if overwrite or not os.path.exists(local_file):
    response = requests.get(db_url)
    response.raise_for_status()  # Ensure the request was successful
    with open(local_file, "wb") as f:
        f.write(response.content)
    # Backup - we will use this to "reset" our DB in each section
    shutil.copy(local_file, backup_file)


# Convert the flights to present time for our tutorial
def update_dates(file):
    shutil.copy(backup_file, file)
    conn = sqlite3.connect(file)
    cursor = conn.cursor()

    tables = pd.read_sql(
        "SELECT name FROM sqlite_master WHERE type='table';", conn
    ).name.tolist()
    tdf = {}
    for t in tables:
        tdf[t] = pd.read_sql(f"SELECT * from {t}", conn)

    example_time = pd.to_datetime(
        tdf["flights"]["actual_departure"].replace("\\N", pd.NaT)
    ).max()
    current_time = pd.to_datetime("now").tz_localize(example_time.tz)
    time_diff = current_time - example_time

    tdf["bookings"]["book_date"] = (
        pd.to_datetime(tdf["bookings"]["book_date"].replace("\\N", pd.NaT), utc=True)
        + time_diff
    )

    datetime_columns = [
        "scheduled_departure",
        "scheduled_arrival",
        "actual_departure",
        "actual_arrival",
    ]
    for column in datetime_columns:
        tdf["flights"][column] = (
            pd.to_datetime(tdf["flights"][column].replace("\\N", pd.NaT)) + time_diff
        )

    for table_name, df in tdf.items():
        df.to_sql(table_name, conn, if_exists="replace", index=False)
    del df
    del tdf
    conn.commit()
    conn.close()

    return file


db = update_dates(local_file)
```

# Tools¶
Next, define our assistant's tools to search the airline's policy manual and search and manage reservations for flights, hotels, car rentals, and excursions. We will reuse these tools throughout the tutorial. The exact implementations aren't important, so feel free to run the code below and jump to Part 1.

**Lookup Company Policies¶**
The assistant retrieve policy information to answer user questions. Note that enforcement of these policies still must be done within the tools/APIs themselves, since the LLM can always ignore this.

```python
import re

import numpy as np
import openai
from langchain_core.tools import tool

response = requests.get(
    "https://storage.googleapis.com/benchmarks-artifacts/travel-db/swiss_faq.md"
)
response.raise_for_status()
faq_text = response.text

docs = [{"page_content": txt} for txt in re.split(r"(?=\n##)", faq_text)]


class VectorStoreRetriever:
    def __init__(self, docs: list, vectors: list, oai_client):
        self._arr = np.array(vectors)
        self._docs = docs
        self._client = oai_client

    @classmethod
    def from_docs(cls, docs, oai_client):
        embeddings = oai_client.embeddings.create(
            model="text-embedding-3-small", input=[doc["page_content"] for doc in docs]
        )
        vectors = [emb.embedding for emb in embeddings.data]
        return cls(docs, vectors, oai_client)

    def query(self, query: str, k: int = 5) -> list[dict]:
        embed = self._client.embeddings.create(
            model="text-embedding-3-small", input=[query]
        )
        # "@" is just a matrix multiplication in python
        scores = np.array(embed.data[0].embedding) @ self._arr.T
        top_k_idx = np.argpartition(scores, -k)[-k:]
        top_k_idx_sorted = top_k_idx[np.argsort(-scores[top_k_idx])]
        return [
            {**self._docs[idx], "similarity": scores[idx]} for idx in top_k_idx_sorted
        ]


retriever = VectorStoreRetriever.from_docs(docs, openai.Client())


@tool
def lookup_policy(query: str) -> str:
    """Consult the company policies to check whether certain options are permitted.
    Use this before making any flight changes performing other 'write' events."""
    docs = retriever.query(query, k=2)
    return "\n\n".join([doc["page_content"] for doc in docs])

```
API Reference: tool

---


# ✈️ **Building a Customer Support Bot for an Airline**  

Customer support bots can significantly reduce the workload of customer service teams by handling common inquiries and tasks. In this tutorial, we'll build a **customer support bot** that assists users with:  
- Booking flights  
- Reserving hotels  
- Renting cars  
- Planning excursions  

We'll use **LangGraph**, a framework designed for managing stateful interactions with language models, and integrate **SQLite** for managing travel-related data.  

---

## 🎯 **Real-World Use Case**  
This customer support bot can be used by airlines like **Emirates** or **Qatar Airways** to:  
- Help customers find flights and hotel packages.  
- Provide information on airline policies (refunds, luggage limits).  
- Manage reservations without human involvement.  

---

## 🛠️ **Prerequisites and Environment Setup**  

Before we start building the bot, let's set up the environment and install the necessary libraries.  

### 🔧 **Step 1: Install Required Packages**  

```python
%%capture --no-stderr
%pip install -U langgraph langchain-community langchain-anthropic tavily-python pandas openai
```

### ✅ **Explanation**  
- **langgraph**: For creating stateful AI workflows.  
- **langchain-community**: Provides LangChain utilities.  
- **langchain-anthropic**: Interface for Claude (LLM).  
- **tavily-python**: For web search capabilities.  
- **pandas**: For data manipulation.  
- **openai**: Access OpenAI models.  

---

### 🔑 **Step 2: Set API Keys**  

We will set up API keys securely using Python's `getpass` module.  

```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("ANTHROPIC_API_KEY")
_set_env("OPENAI_API_KEY")
_set_env("TAVILY_API_KEY")
```

### 📝 **Explanation (Line-by-Line)**  
- **getpass.getpass()**: Securely takes API keys without showing them in the console.  
- **os.environ**: Sets environment variables for later use.  
- **_set_env function**: Checks if the variable exists, if not, prompts for it.  

---

## 💾 **Populate the Database**  

Now, let's set up the **SQLite database** that contains flight, hotel, and car rental data.  

### 🧩 **Step 3: Download and Prepare the Database**  

```python
import os
import shutil
import sqlite3
import pandas as pd
import requests

db_url = "https://storage.googleapis.com/benchmarks-artifacts/travel-db/travel2.sqlite"
local_file = "travel2.sqlite"
backup_file = "travel2.backup.sqlite"
overwrite = False

if overwrite or not os.path.exists(local_file):
    response = requests.get(db_url)
    response.raise_for_status()  # Check for successful download
    with open(local_file, "wb") as f:
        f.write(response.content)
    shutil.copy(local_file, backup_file)
```

### 🔍 **Explanation**  
- **requests.get(db_url)**: Downloads the SQLite database.  
- **shutil.copy**: Creates a backup for resetting during the tutorial.  
- **os.path.exists()**: Checks if the database already exists to avoid re-downloading.  

---

### ⏰ **Step 4: Update Flight Dates to Current Time**  

We will ensure the flight times in the database reflect the current time for a realistic simulation.  

```python
def update_dates(file):
    shutil.copy(backup_file, file)
    conn = sqlite3.connect(file)
    cursor = conn.cursor()

    tables = pd.read_sql("SELECT name FROM sqlite_master WHERE type='table';", conn).name.tolist()
    tdf = {t: pd.read_sql(f"SELECT * from {t}", conn) for t in tables}

    example_time = pd.to_datetime(tdf["flights"]["actual_departure"].replace("\\N", pd.NaT)).max()
    current_time = pd.to_datetime("now").tz_localize(example_time.tz)
    time_diff = current_time - example_time

    tdf["bookings"]["book_date"] += time_diff
    datetime_columns = ["scheduled_departure", "scheduled_arrival", "actual_departure", "actual_arrival"]
    for column in datetime_columns:
        tdf["flights"][column] += time_diff

    for table_name, df in tdf.items():
        df.to_sql(table_name, conn, if_exists="replace", index=False)

    conn.commit()
    conn.close()

    return file

db = update_dates(local_file)
```

### 📜 **Explanation**  
- **sqlite3.connect()**: Connects to the SQLite database.  
- **pandas.read_sql()**: Reads tables from the database.  
- **pd.to_datetime()**: Converts date columns to datetime objects for manipulation.  
- **time_diff**: Calculates the time difference and updates all relevant date fields.  
- **df.to_sql()**: Saves the updated data back into the database.  

---

## 🔎 **Assistant's Tools**  

Our bot needs tools to:  
- Search for company policies.  
- Handle bookings (flights, hotels, cars, excursions).  

---

### 📚 **Step 5: Lookup Company Policies**  

We'll create a **policy retriever** that searches the company's policies to answer user questions.

```python
import re
import numpy as np
import openai
from langchain_core.tools import tool

response = requests.get("https://storage.googleapis.com/benchmarks-artifacts/travel-db/swiss_faq.md")
response.raise_for_status()
faq_text = response.text
docs = [{"page_content": txt} for txt in re.split(r"(?=\n##)", faq_text)]

class VectorStoreRetriever:
    def __init__(self, docs: list, vectors: list, oai_client):
        self._arr = np.array(vectors)
        self._docs = docs
        self._client = oai_client

    @classmethod
    def from_docs(cls, docs, oai_client):
        embeddings = oai_client.embeddings.create(
            model="text-embedding-3-small", input=[doc["page_content"] for doc in docs]
        )
        vectors = [emb.embedding for emb in embeddings.data]
        return cls(docs, vectors, oai_client)

    def query(self, query: str, k: int = 5) -> list[dict]:
        embed = self._client.embeddings.create(
            model="text-embedding-3-small", input=[query]
        )
        scores = np.array(embed.data[0].embedding) @ self._arr.T
        top_k_idx = np.argpartition(scores, -k)[-k:]
        top_k_idx_sorted = top_k_idx[np.argsort(-scores[top_k_idx])]
        return [{**self._docs[idx], "similarity": scores[idx]} for idx in top_k_idx_sorted]

retriever = VectorStoreRetriever.from_docs(docs, openai.Client())

@tool
def lookup_policy(query: str) -> str:
    """Consult company policies for permitted options."""
    docs = retriever.query(query, k=2)
    return "\n\n".join([doc["page_content"] for doc in docs])
```

---

### ✨ **Explanation**  
- **openai.embeddings.create()**: Generates numerical embeddings for each policy document.  
- **numpy array operations (@)**: Calculates similarity between user queries and policy documents.  
- **top_k_idx**: Selects the most relevant documents based on similarity scores.  
- **@tool decorator**: Registers `lookup_policy` as a tool accessible by the LangGraph assistant.  

---

### 🌟 **Example Scenario**  
**User Query:** *"Can I bring a pet onboard?"*  
**Bot Response:** The bot will use `lookup_policy` to fetch relevant policy documents and inform the user about airline pet policies.  

---

## 🏁 **Conclusion**  

🎉 **Congratulations!** You have learned how to:  
- Set up a customer support bot using **LangGraph**.  
- Connect and update a **SQLite database** for travel data.  
- Build a **policy retriever tool** using **OpenAI embeddings**.  

💡 **Next Steps:**  
- Implement booking tools for flights, hotels, and car rentals.  
- Add conversational memory to handle long conversations.  
- Deploy the bot and integrate it with real-time APIs.  

Would you like me to guide you on how to implement booking features or deploy this bot? 😊