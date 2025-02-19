# ✈️ **Build a Customer Support Bot for an Airline**  

Customer support bots help businesses by automating responses to common queries, saving time, and enhancing customer experience. In this tutorial, we will build a **customer support bot** for an **airline** that assists users with:  
- Booking flights  
- Reserving hotels  
- Renting cars  
- Suggesting excursions  

We'll use **LangGraph**, **Claude (LLM)**, and **SQLite database**. We'll also integrate **web search** using **Tavily**.  

By the end of this tutorial, you'll:  
✅ Understand LangGraph's key concepts like **interrupts**, **checkpointers**, and **complex states**.  
✅ Build a fully functional airline customer support chatbot.  
✅ Be able to apply these patterns to other AI projects.  

---

## 🌟 **Real-World Use Case**  
Imagine you're running an airline company like **Emirates** or **Qatar Airways**. You want to reduce the workload on customer service teams by automating tasks like:  
- Booking flight tickets  
- Managing hotel and car rental queries  
- Providing travel recommendations  

A chatbot can handle these tasks 24/7, improving customer satisfaction and cutting operational costs.  

---

## 🛠️ **Prerequisites**  
Before we dive into coding, let’s set up our environment.  

### ✅ **Step 1: Install Required Libraries**  
We'll install the following libraries:  
- `langgraph`: For creating graph-based workflows.  
- `langchain-community`: For community integrations.  
- `langchain-anthropic`: To use Claude LLM.  
- `tavily-python`: For web search integration.  
- `pandas`: For handling data.  
- `openai`: For OpenAI’s API access.

### 💻 **Code: Install Packages**  
```python
%%capture --no-stderr
%pip install -U langgraph langchain-community langchain-anthropic tavily-python pandas openai
```

### 📝 **Explanation**  
- `%%capture --no-stderr`: Jupyter magic command to suppress output.  
- `%pip install -U`: Installs the packages and upgrades them if they exist.  
- The listed packages will enable our bot to perform various tasks like searching the web, managing databases, and using AI models.  

---

### 🔒 **Step 2: Set Up API Keys**  
To interact with AI models and perform web searches, we need API keys. We’ll securely set them using Python's `os` and `getpass` libraries.  

### 💻 **Code: Set Environment Variables**  
```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

# Set API keys for external services
_set_env("ANTHROPIC_API_KEY")
_set_env("OPENAI_API_KEY")
_set_env("TAVILY_API_KEY")
```

### 📝 **Explanation**  
- **`import getpass`**: For secure input of sensitive data like API keys.  
- **`import os`**: To manage environment variables.  
- **`_set_env()`**:  
  - Checks if the variable exists in the environment.  
  - If not, prompts the user securely to enter the key.  
- **Why environment variables?** ✅ They protect sensitive data from being hardcoded into the script.  

---

## 🌐 **Step 3: Setting Up LangSmith for Debugging**  
**LangSmith** allows you to debug, test, and monitor your LLM apps. It uses trace data to analyze the performance of your LangGraph projects.  

**Why LangSmith?**  
- Quickly spot and fix issues  
- Visualize the flow of your chatbot  
- Optimize LLM performance  

### 💡 **Real-World Example:**  
If your bot fails to book a flight, LangSmith will help you see where the issue occurred — whether it's the database query, LLM misunderstanding, or API connection.

---

## 🏗️ **Next Steps**  
1️⃣ Connect a **SQLite database** to store flight, hotel, and car rental data.  
2️⃣ Build **custom tools** that:  
   - Search for flights  
   - Book hotels  
   - Rent cars  
   - Suggest excursions  
3️⃣ Integrate **Claude (LLM)** for natural language understanding.  
4️⃣ Use **LangGraph interrupts and checkpointers** to manage conversation flow.

---

## 💡 **Example Use Case in Action**  
**Scenario:**  
A customer wants to book a flight from **Karachi** to **Dubai**, rent a car, and book a hotel.  

### 🛫 **Bot Conversation Flow:**  
1. **User**: "I want to fly from Karachi to Dubai on 10th March."  
2. **Bot**: "Available flights on 10th March are Emirates EK-601 at 10 AM and PIA PK-213 at 2 PM. Which one would you prefer?"  
3. **User**: "Emirates EK-601."  
4. **Bot**: "Flight booked! Would you like to reserve a hotel or rent a car in Dubai?"  
5. **User**: "Yes, I need both."  
6. **Bot**: "Here are some hotels and rental options. Please choose your preferences."  

---

## 🔄 **Explaining LangGraph Concepts with Examples**  

### 🔀 **Interrupts**  
Interrupts help pause the conversation when the bot needs more information from the user.  
**Example:**  
- If the user says "Book a flight," but doesn’t mention the destination, the bot will pause and ask, "Where would you like to go?"  

### 💾 **Checkpointers**  
Checkpointers save the state of the conversation so that the bot can resume if interrupted.  
**Example:**  
- If the user books a flight but leaves before confirming hotel details, the bot will remember the last step and continue from there when the user returns.  

---

## 💬 **Next Section Teaser:**  
✨ In the next section, we’ll:  
- Build the **SQLite database** for flight, hotel, and car rental data.  
- Implement **functions** to query this database.  
- Create **LangGraph nodes** for each booking step.  

Would you like me to continue with the database and function implementation? 😊

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