# 🎯 **Returning Structured Data from a Model**  

When working with **Large Language Models (LLMs)**, we often need the output to **follow a specific format** instead of just free-form text. This is particularly useful for:  

✅ **Extracting data** from text to insert into a database  
✅ **Processing responses** in a structured way for applications  
✅ **Calling functions/tools** dynamically based on structured output  

This guide will explore how to return structured data using the `.with_structured_output()` method.

---

## 🛠️ **Prerequisites**  

Before diving in, ensure you're familiar with:  

🔹 **Chat Models** – LLMs that generate conversational responses  
🔹 **Function/Tool Calling** – Using external tools to process data  

---

## 🚀 **Why Use Structured Outputs?**  

LLMs generate text, but unstructured responses can be hard to work with. Imagine you're building a chatbot that extracts user information from conversations. Instead of getting a **messy response**, you'd want the output in a **clean, structured format** like JSON.  

💡 **Example Use Case:**  
A customer support bot extracts the **user’s name, email, and issue** and returns it as:  

```json
{
  "name": "Alice",
  "email": "alice@example.com",
  "issue": "Cannot log into my account"
}
```

This structured format makes it easy to store, process, and act upon the data.

---

# 🏗️ **How to Get Structured Outputs Using `.with_structured_output()`**  

`.with_structured_output()` is the **simplest and most reliable** way to get structured responses. It allows models to return **objects** instead of plain text.

🔹 **Supported Models:** It works with models that provide **native APIs** for structured output, such as:
- **Tool/Function Calling**
- **JSON Mode**  

This method takes a **schema** as input, defining:
✅ **Names** of the fields  
✅ **Data Types** (e.g., string, integer, boolean)  
✅ **Descriptions** of each attribute  

---

## **🔹 Defining a Schema for Structured Output**  

The schema can be specified using:  
1️⃣ **TypedDict (Python’s type hints for dictionaries)**  
2️⃣ **JSON Schema (Standardized JSON structure)**  
3️⃣ **Pydantic (Data validation library for Python)**  

📌 **Difference Between Schema Types:**  
| Schema Type  | Output Format  |
|-------------|---------------|
| **TypedDict / JSON Schema**  | Returns a dictionary  |
| **Pydantic Class**  | Returns a Pydantic object |

---

## **💡 Example: Generating a Joke with Structured Output**  

Let's say we want an AI model to generate a **joke**, separating the **setup** from the **punchline**.

### 🔹 **Step 1: Install Dependencies**  
First, install `langchain` with **Groq API support**:  

```bash
pip install -qU "langchain[groq]"
```

### 🔹 **Step 2: Set Up API Key**  
Groq requires an **API key** for authentication. Set it up like this:  

```python
import getpass
import os

# Set API key if not already set
if not os.environ.get("GROQ_API_KEY"):
    os.environ["GROQ_API_KEY"] = getpass.getpass("Enter API key for Groq: ")
```

🔹 **What this does:**  
- Checks if the `GROQ_API_KEY` is already set in the environment  
- If not, it prompts the user to enter it securely  

---

### 🔹 **Step 3: Initialize the Chat Model**  

```python
from langchain.chat_models import init_chat_model

# Initialize Llama3 model from Groq
llm = init_chat_model("llama3-8b-8192", model_provider="groq")
```

🔹 **What this does:**  
- Initializes a **chat model** using `llama3-8b-8192`  
- Specifies **Groq** as the model provider  

---

### 🔹 **Step 4: Define the Schema Using TypedDict**  

```python
from typing import TypedDict

class JokeSchema(TypedDict):
    setup: str
    punchline: str
```

🔹 **What this does:**  
- Defines a **schema** with two fields:  
  - `setup` (string) – The first part of the joke  
  - `punchline` (string) – The punchline of the joke  
- Uses **TypedDict** to enforce structured output  

---

### 🔹 **Step 5: Generate Structured Output**  

```python
# Create an LLM with structured output
structured_llm = llm.with_structured_output(JokeSchema)

# Generate a joke
response = structured_llm.invoke("Tell me a funny joke.")

print(response)
```

🔹 **What this does:**  
- **Wraps the LLM** with `.with_structured_output()` to enforce structured responses  
- **Invokes** the model with `"Tell me a funny joke."`  
- **Prints the structured output**, which will look like:

```json
{
  "setup": "Why don't skeletons fight each other?",
  "punchline": "Because they don't have the guts!"
}
```

---

## **🎯 Real-World Applications**  

Structured outputs are incredibly useful in many applications:  

📌 **1. Chatbots & Virtual Assistants**  
- Extract user info: `{"name": "Alice", "email": "alice@example.com"}`  
- Route customer requests based on structured queries  

📌 **2. Data Extraction & Processing**  
- Convert unstructured text into structured data for **databases**  
- Extract financial information from documents  

📌 **3. Automated Workflows**  
- Generate structured reports from AI-generated content  
- Provide **API-ready responses** for external applications  

---

## **🚀 Summary**
✔️ **Structured outputs** make AI responses predictable and easy to process.  
✔️ `.with_structured_output()` ensures LLM responses follow a specific format.  
✔️ **TypedDict, JSON Schema, and Pydantic** are used to define schemas.  
✔️ **Real-world applications** include chatbots, automation, and data extraction.

Would you like an example using **Pydantic** instead of TypedDict? 😃

---
# 🏗️ How to Return Structured Data from a Model

When working with AI models, sometimes we need structured data instead of plain text responses. This is especially useful for applications that store AI-generated data in a database or integrate with other systems. In this guide, we'll explore different ways to return structured data using **Pydantic**, **TypedDict**, and **JSON Schema**.

---

## 📌 **Why Do We Need Structured Data?**
- 🔹 **Easier Data Processing:** JSON-like outputs can be directly stored or used in applications.
- 🔹 **Data Validation:** Ensures that the output has the correct format and required fields.
- 🔹 **Better Integration:** Makes it easier to use AI-generated data in APIs, databases, and automation.

### 🎯 **Real-World Use Cases**
1. **Chatbots & Assistants** 🗣️  
   - Extracting structured responses like FAQs, support tickets, or product recommendations.
2. **E-Commerce Applications** 🛒  
   - Extracting product details like price, description, and stock levels.
3. **Healthcare Systems** 🏥  
   - Extracting patient symptoms and structured diagnoses from doctor-patient conversations.

---

# 🛠️ **Methods for Structured Data Output**
## 📌 **1. Using Pydantic for Data Validation**
Pydantic is a Python library for **data validation** and **serialization**. It ensures that the AI model returns correctly formatted data.

### ✅ **Advantages of Using Pydantic**
✔️ Ensures that data is correctly formatted.  
✔️ Raises an error if a required field is missing.  
✔️ Provides automatic type conversion.

### 📝 **Example: AI Model Returns a Joke in a Structured Format**
```python
from typing import Optional
from pydantic import BaseModel, Field

# 🎭 Define a structured response using Pydantic
class Joke(BaseModel):
    """Joke format for AI response."""

    setup: str = Field(description="The setup of the joke")
    punchline: str = Field(description="The punchline of the joke")
    rating: Optional[int] = Field(default=None, description="Joke rating from 1 to 10")

# Simulate AI model output
def generate_joke():
    return Joke(setup="Why was the cat sitting on the computer?", 
                punchline="Because it wanted to keep an eye on the mouse!", 
                rating=7)

# 🏗️ Get structured output
joke = generate_joke()
print(joke.json())  # Convert to JSON format
```

### 🔍 **Explanation of Code**
1. **`BaseModel`**: Defines a structured class using Pydantic.
2. **`Field(description="...")`**: Adds metadata for better AI understanding.
3. **`Optional[int]`**: The `rating` field is optional.
4. **`generate_joke()`**: Simulates AI output.
5. **`joke.json()`**: Converts the joke to JSON format.

### ✅ **Example Output**
```json
{
  "setup": "Why was the cat sitting on the computer?",
  "punchline": "Because it wanted to keep an eye on the mouse!",
  "rating": 7
}
```

---

## 📌 **2. Using TypedDict (Alternative to Pydantic)**
If you **don’t need validation**, you can use `TypedDict` from `typing_extensions`. This is useful when working with **streaming outputs**.

### 📝 **Example**
```python
from typing import Optional
from typing_extensions import Annotated, TypedDict

# 🏗️ Define a joke structure
class Joke(TypedDict):
    """Joke format for AI response."""

    setup: Annotated[str, ..., "The setup of the joke"]
    punchline: Annotated[str, ..., "The punchline of the joke"]
    rating: Annotated[Optional[int], None, "Joke rating from 1 to 10"]

# Simulate AI model output
joke: Joke = {
    "setup": "Why don't skeletons fight each other?",
    "punchline": "Because they don't have the guts!",
    "rating": 8
}

print(joke)
```

### 🔍 **Explanation of Code**
1. **`TypedDict`**: Defines a dictionary-like structure.
2. **`Annotated[str, ...]`**: Specifies field descriptions.
3. **`Optional[int]`**: Allows the `rating` field to be optional.

### ✅ **Example Output**
```json
{
  "setup": "Why don't skeletons fight each other?",
  "punchline": "Because they don't have the guts!",
  "rating": 8
}
```

---

## 📌 **3. Using JSON Schema for Maximum Flexibility**
Instead of using classes, we can directly define a **JSON Schema**.

### 📝 **Example**
```python
json_schema = {
    "title": "Joke",
    "description": "Joke format for AI response.",
    "type": "object",
    "properties": {
        "setup": {"type": "string", "description": "The setup of the joke"},
        "punchline": {"type": "string", "description": "The punchline of the joke"},
        "rating": {"type": "integer", "description": "Joke rating from 1 to 10", "default": None}
    },
    "required": ["setup", "punchline"]
}

# Simulated AI model output
ai_response = {
    "setup": "What did one wall say to the other?",
    "punchline": "I'll meet you at the corner.",
    "rating": 6
}

print(ai_response)
```

### 🔍 **Explanation of Code**
1. **Defines JSON schema** to specify expected data format.
2. **AI response follows the schema** with `setup`, `punchline`, and `rating`.

### ✅ **Example Output**
```json
{
  "setup": "What did one wall say to the other?",
  "punchline": "I'll meet you at the corner.",
  "rating": 6
}
```

---

# 🔄 **Choosing Between Multiple Response Types**
Sometimes, a model might return different types of responses. For example:
- **If the user asks for a joke**, return a `Joke` object.
- **If the user asks a general question**, return a `ConversationalResponse`.

## ✅ **Using Pydantic with `Union`**
```python
from typing import Union

class ConversationalResponse(BaseModel):
    """General AI response."""
    response: str = Field(description="A conversational response.")

class FinalResponse(BaseModel):
    """AI can return either a joke or a general response."""
    final_output: Union[Joke, ConversationalResponse]

# 🏗️ Simulated AI Model Responses
joke_response = FinalResponse(final_output=Joke(setup="Why don't scientists trust atoms?",
                                                punchline="Because they make up everything!",
                                                rating=9))

conversation_response = FinalResponse(final_output=ConversationalResponse(response="I'm here to help!"))

print(joke_response.json())
print(conversation_response.json())
```

### ✅ **Example Output**
```json
{
  "final_output": {
    "setup": "Why don't scientists trust atoms?",
    "punchline": "Because they make up everything!",
    "rating": 9
  }
}
```

---
# Understanding JSON Mode and Structured Output in LangChain

When working with language models, **structured output** is essential for extracting useful data from the responses. This is where **JSON mode** and tools like **PydanticOutputParser** come into play. They allow us to get consistent and easy-to-parse outputs from language models.

In this article, we will explain **JSON mode** in LangChain, how it works, and how we can use it to parse structured data. We’ll also explore how to implement this in code with real-world examples.

### What is JSON Mode?

**JSON mode** allows a model to output data in a structured **JSON** format, making it easier to process programmatically. This is useful when we need the model's responses to adhere to a specific schema, so we can easily use them in other parts of the application without manual parsing.

### Why Use Structured Output?

Structured outputs are helpful in various scenarios:
- **Extracting Data**: When working with user queries, we often need to extract specific information, like names, dates, or quantities, from free text.
- **Consistency**: Structured output ensures that the responses from the model always follow the same format, which is easier to handle programmatically.
- **Scalability**: In complex applications, structured data makes it easier to manage, transform, or store the results.

### Real-World Example

Imagine a chatbot in a healthcare application. When a user provides their health data, like their age and height, the system needs to parse this information, process it, and store it in a database. Structured output, like JSON, ensures the data is cleanly captured, and we can easily transform it into a database entry.

Example JSON output:
```json
{
  "people": [
    {
      "name": "Anna",
      "height_in_meters": 1.8288
    }
  ]
}
```

### Using LangChain with JSON Mode

LangChain is a powerful framework that integrates **structured output** into the LLMs, allowing you to define specific formats for the model's responses.

---

## Example Code Walkthrough: Using JSON Mode

Here’s how we can structure outputs using **JSON mode** and **PydanticOutputParser** in LangChain:

### Step 1: Define the Data Model

First, we define the data model that the response should follow. For this, we'll use **Pydantic**, a Python library for data validation, to create a schema that the model’s output must adhere to.

```python
from pydantic import BaseModel, Field
from typing import List

# Defining a Person model
class Person(BaseModel):
    name: str
    height_in_meters: float

# Defining a model for a list of people
class People(BaseModel):
    people: List[Person]
```

Here:
- `Person` model holds information about a person, including their `name` and `height_in_meters`.
- `People` model is a container for a list of `Person` objects.

### Step 2: Prepare the LangChain Prompt

Next, we define a **prompt template** using LangChain that will format the output as JSON:

```python
from langchain_core.prompts import ChatPromptTemplate

# Create the prompt template
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "Answer the user query. Wrap the output in `json` tags\n{format_instructions}"),
        ("human", "{query}"),
    ]
).partial(format_instructions='{"type": "object", "properties": {"people": {"type": "array", "items": {"type": "object", "properties": {"name": {"type": "string"}, "height_in_meters": {"type": "number"}}}}}}')

# This ensures the model will wrap the output in valid JSON.
```

Here:
- `system`: This part of the prompt tells the model to wrap the output in `json` tags.
- `human`: This part passes the query from the user.

### Step 3: Use the Pydantic Output Parser

Now we need to parse the output from the model. This is where **PydanticOutputParser** comes in handy:

```python
from langchain_core.output_parsers import PydanticOutputParser

# Set up the parser with the People model
parser = PydanticOutputParser(pydantic_object=People)
```

### Step 4: Invoke the Chain

The final step is to combine the prompt, model, and parser into a **chain**. This will execute the model and automatically parse the output:

```python
chain = prompt | llm | parser

# Define the query
query = "Anna is 23 years old and she is 6 feet tall"

# Execute the chain
response = chain.invoke({"query": query})

# This will return a parsed response based on the defined schema
print(response)  # Output: People(people=[Person(name='Anna', height_in_meters=1.8288)])
```

### Explanation of Code

- **`ChatPromptTemplate`**: This creates a structured prompt that will ensure the model responds with JSON.
- **`PydanticOutputParser`**: This parser converts the raw model output into a `People` object, based on the schema we defined.
- **`invoke()`**: This method triggers the model to generate a response based on the query, formats it into JSON, and parses it using Pydantic.

### Step 5: Extract JSON from Raw Output (Advanced Parsing)

In some cases, you may need to manually extract and parse JSON from a raw string. Here's how you can do that:

```python
import json
import re

# Function to extract JSON from raw output
def extract_json(message: AIMessage) -> List[dict]:
    pattern = r"\`\`\`json(.*?)\`\`\`"  # Regex pattern to find JSON within `json` tags
    matches = re.findall(pattern, message.content, re.DOTALL)

    try:
        return [json.loads(match.strip()) for match in matches]
    except Exception:
        raise ValueError(f"Failed to parse: {message}")

# Extract JSON from the raw model response
raw_response = "The raw response here with `json` format"
parsed_data = extract_json(raw_response)
print(parsed_data)  # Output will be a parsed JSON object
```

### Key Takeaways:

- **JSON Mode** allows the model to output structured data that is easy to parse and use in real-world applications.
- **LangChain** makes it easy to implement structured outputs and integrate them into your workflows.
- Using **PydanticOutputParser**, you can automatically validate and convert the model’s raw output into structured data.

### Real-World Usage Example: Personal Assistant

Imagine you're building a personal assistant that processes various data, such as names, locations, and dates from user input. By using JSON mode, you can consistently extract structured information from user queries (e.g., "Anna is in New York and she's 5'10" tall"). The assistant can then use that data to provide further responses, like confirming travel details or updating calendars.

---

By using **structured output** and **JSON mode** in LangChain, we can make our applications smarter, more efficient, and much easier to scale.