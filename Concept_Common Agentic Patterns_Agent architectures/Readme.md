# 🏗️ **Agent Architectures in AI**  

Large Language Models (LLMs) are often used in applications that follow a predefined series of steps before or after making calls to the model. However, for more complex tasks, we need LLM systems that **decide their own control flow** instead of following a fixed path. This is where **agent architectures** come into play.  

---

## 🚀 **What is an Agent?**  

An **agent** is a system that **uses an LLM to determine the control flow** of an application. Instead of rigidly following predefined steps, agents allow LLMs to make decisions about:  

✅ **Routing:** Choosing between multiple possible paths  
✅ **Tool Selection:** Deciding which external tool or API to call  
✅ **Self-Assessment:** Determining whether more work is needed before responding  

These flexible decision-making capabilities enable agents to handle more **dynamic and complex tasks** compared to traditional LLM-based applications.

---

## 🏗️ **Types of Agent Architectures**  

There are different architectures that give LLMs varying levels of control. The most common types include:  

### 🛤️ **1. Router Agents**  
A **router agent** selects **one step from a predefined set of options**. This provides a structured way for an LLM to **choose between different pathways** based on the user’s input.  

💡 **Example Use Case:**  
- In a **customer support chatbot**, a router agent decides whether to:  
  - Answer the question directly  
  - Redirect to a live agent  
  - Fetch additional data before responding  

### 🧩 **2. Structured Outputs**  
Structured outputs ensure that the LLM’s responses follow a **specific format**. This is helpful when the output needs to be reliably processed by another system.  

📌 **Techniques for Structured Outputs:**  
1️⃣ **Prompt Engineering** – Instructing the LLM to return data in a specific format  
2️⃣ **Output Parsers** – Extracting key data using post-processing  
3️⃣ **Tool Calling** – Using external functions to generate responses  

💡 **Example Use Case:**  
- A **weather chatbot** might need to return responses in JSON format so that another application can parse the data easily.  

---

## 🛠️ **Code Example: Router Agent**  

Let’s implement a **simple router agent** using OpenAI’s GPT model to decide whether to **fetch information from an API** or **answer directly**.  

### **🔹 Step 1: Install Dependencies**  
First, install the required library:  
```bash
pip install openai
```

### **🔹 Step 2: Implement the Router Agent**  
```python
import openai  

def router_agent(user_input):  
    """Decides whether to fetch data from an API or answer directly."""  

    prompt = f"""You are an AI agent. Given the user question: "{user_input}",  
    decide whether to fetch external data or answer directly.  
    Respond with 'FETCH' if data retrieval is needed, otherwise respond with 'ANSWER'."""  

    response = openai.ChatCompletion.create(  
        model="gpt-4",  
        messages=[{"role": "system", "content": "You are a routing assistant."},  
                  {"role": "user", "content": prompt}]  
    )  

    decision = response["choices"][0]["message"]["content"].strip()  
    return decision  

# Example Usage
user_query = "What is the current weather in Karachi?"  
decision = router_agent(user_query)  
print(f"Decision: {decision}")  
```

### **🔍 Code Explanation**
1️⃣ **Define the `router_agent` function** – It takes user input and determines whether to fetch data or respond directly.  
2️⃣ **Construct a prompt** – The LLM is asked to decide whether an external API call is required.  
3️⃣ **Call OpenAI’s API** – The model processes the request and returns either `'FETCH'` or `'ANSWER'`.  
4️⃣ **Extract the decision** – The result is returned and printed.  

### **💡 Real-World Scenario**
This type of routing agent could be used in **news applications**, where an LLM decides whether to generate a summary from existing knowledge or fetch **real-time news articles** from an API.

---

## **🌟 Summary**
✔️ **Agent architectures** allow LLMs to control their own flow of decisions.  
✔️ **Router agents** are useful for selecting between multiple pathways.  
✔️ **Structured outputs** ensure LLM responses are well-formatted for processing.  
✔️ **Real-world applications** include chatbots, decision-making systems, and dynamic content generation.

Would you like to see an example of **tool selection agents** or **self-assessing agents** next? 😊

---
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

# 🌀 **Understanding Streaming in Structured Outputs**  

Streaming structured outputs is a powerful way to process and display data incrementally as it's being generated. Instead of waiting for an entire response, we can receive and process small parts (chunks) of the output dynamically.  

This concept is particularly useful in scenarios like AI-generated content, chatbots, and real-time data processing. Let's break it down in **simple terms** with **examples** and **real-world applications**.

---

## 🔹 **What is Streaming?**  

🔹 **Streaming** is a method where data is received **gradually** rather than all at once. This is helpful when dealing with large responses or real-time interactions, as it improves **performance** and **user experience**.  

---

## 🔹 **How Does Streaming Work in Structured Models?**  

When using structured models, we can stream outputs **only if the output type is a dictionary (`dict`)**, such as a **TypedDict** class or a **JSON Schema dictionary**.  

### ✅ **Key Takeaways**  

- We can use **TypedDict** to define structured data with expected keys and types.  
- The streamed output is **aggregated chunks**, meaning we receive complete segments instead of tiny differences (deltas).  
- This approach is useful when building AI applications that **respond dynamically** while processing information.  

---

## 🔹 **Understanding the Code**  

### 📌 **Step 1: Import Required Modules**  

```python
from typing_extensions import Annotated, TypedDict
```
- `TypedDict` allows defining a structured dictionary with specific **key-value** types.  
- `Annotated` provides **metadata** about each field, such as descriptions.  

---

### 📌 **Step 2: Define a Structured Output (TypedDict)**  

```python
# Define a structured format for a joke
class Joke(TypedDict):
    """Joke to tell user."""
    setup: Annotated[str, ..., "The setup of the joke"]
    punchline: Annotated[str, ..., "The punchline of the joke"]
    rating: Annotated[Optional[int], None, "How funny the joke is, from 1 to 10"]
```
- This class defines a **dictionary structure** with three fields:  
  1. `setup`: The **first part** of the joke (string).  
  2. `punchline`: The **funny ending** of the joke (string).  
  3. `rating`: A **numeric rating** (1-10) indicating how funny it is (optional).  

---

### 📌 **Step 3: Generate a Streamed Response**  

```python
structured_llm = llm.with_structured_output(Joke)

for chunk in structured_llm.stream("Tell me a joke about cats"):
    print(chunk)
```
- `llm.with_structured_output(Joke)`:  
  - Configures the **language model (LLM)** to return responses in the **Joke format**.  
- `structured_llm.stream("Tell me a joke about cats")`:  
  - Generates and **streams** the joke **one piece at a time**.  

---

### 📌 **Step 4: Output Breakdown**  

```
{}
{'setup': ''}
{'setup': 'Why'}
{'setup': 'Why was'}
{'setup': 'Why was the'}
{'setup': 'Why was the cat'}
...
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the mouse!'}
```
🔹 **What's happening here?**  
- At first, we receive an **empty dictionary `{}`**.  
- Gradually, the **setup** field builds **word by word**.  
- Once the **setup is complete**, the **punchline** starts appearing.  

💡 **This approach makes responses feel more dynamic and responsive instead of waiting for the full joke.**  

---

## 🎯 **Real-World Applications of Streaming**  

### 1️⃣ **Chatbots & Virtual Assistants** 🤖  
- Instead of making users wait for a full response, **chatbots** can **stream replies** gradually, improving engagement.  

### 2️⃣ **Live Transcription & Subtitles** 🎤  
- Services like **YouTube subtitles** and **Zoom captions** stream text **as the person speaks**.  

### 3️⃣ **Code Assistants (e.g., GitHub Copilot, ChatGPT Code Completion)** 💻  
- When generating code, **streaming** helps display **partial code suggestions** dynamically.  

---

## 🔄 **Alternative Examples**  

### ✅ **Example 1: Streaming a Live News Update** 📰  
```python
from typing_extensions import Annotated, TypedDict

class NewsUpdate(TypedDict):
    """Breaking news updates."""
    headline: Annotated[str, ..., "The news headline"]
    details: Annotated[str, ..., "Details of the news"]
    
news_llm = llm.with_structured_output(NewsUpdate)

for chunk in news_llm.stream("Give me breaking news on technology"):
    print(chunk)
```
📌 **Use Case**: A news application that **streams** breaking news updates **as they arrive**.  

---

### ✅ **Example 2: Streaming a Story Generation** 📖  
```python
class Story(TypedDict):
    """Generated short story."""
    title: Annotated[str, ..., "Story title"]
    content: Annotated[str, ..., "The main story"]
    
story_llm = llm.with_structured_output(Story)

for chunk in story_llm.stream("Tell me a short horror story"):
    print(chunk)
```
📌 **Use Case**: A **story-writing AI** that streams **sentence by sentence**, making it feel like a book is being written in real time.  

---

### ✅ **Example 3: Streaming Stock Market Updates** 📈  
```python
class StockUpdate(TypedDict):
    """Live stock market updates."""
    symbol: Annotated[str, ..., "Stock ticker symbol"]
    price: Annotated[float, ..., "Current stock price"]
    
stock_llm = llm.with_structured_output(StockUpdate)

for chunk in stock_llm.stream("Get live updates for Apple stock"):
    print(chunk)
```
📌 **Use Case**: A **real-time stock tracking** system that updates stock prices **as the market changes**.  

---

## 🎯 **Why is Streaming Useful?**  

✅ **Faster Response Times**: Instead of waiting for full output, users see **partial results quickly**.  
✅ **Improved User Experience**: Feels more **dynamic**, just like how **real conversations work**.  
✅ **Better Resource Management**: Streaming reduces **memory usage** compared to waiting for the full response.  

---

## 🏆 **Conclusion**  

📌 Streaming structured outputs **enhances performance and interactivity** by providing incremental results instead of waiting for a complete response.  

📌 It is used in **chatbots, live trans

---

# 🧠 **Understanding Few-Shot Prompting in AI Models**  

Few-shot prompting is an essential technique in prompt engineering that helps AI models generate better-structured and more relevant responses by providing a few examples within the prompt. This guide will break down the concept in detail, making it easy for beginners to understand, along with real-world use cases, alternative examples, and code snippets.  

---

## 🔍 **What is Few-Shot Prompting?**  

Few-shot prompting is a method where you provide the AI model with a few examples (or "shots") of how it should respond before asking it to generate a new response. This helps guide the model towards the expected structure and tone.  

### 🏆 **Why Use Few-Shot Prompting?**  
✅ Helps AI understand the expected response format.  
✅ Reduces randomness in AI-generated outputs.  
✅ Improves accuracy for complex or structured outputs.  
✅ Works well for structured data generation (e.g., JSON, TypedDict).  

---

# 🛠 **1. Basic Example of Few-Shot Prompting**  

## **📌 Step 1: Define a System Message with Examples**  
The **system message** acts as an instruction to the AI, telling it how to behave and what kind of responses to generate.  

### 📜 **Code Example**
```python
from langchain_core.prompts import ChatPromptTemplate

# Define the system message with examples
system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke with a setup and a punchline.

Here are some examples:

example_user: Tell me a joke about planes
example_assistant: {"setup": "Why don't planes ever get tired?", "punchline": "Because they have rest wings!", "rating": 2}

example_user: Tell me another joke about planes
example_assistant: {"setup": "Cargo", "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!", "rating": 10}

example_user: Now about caterpillars
example_assistant: {"setup": "Caterpillar", "punchline": "Caterpillar really slow, but watch me turn into a butterfly and steal the show!", "rating": 5}"""

# Create the prompt
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{input}")])

# Invoke the AI model with structured output
few_shot_structured_llm = prompt | structured_llm
result = few_shot_structured_llm.invoke("Tell me something funny about woodpeckers")

print(result)
```

### ✅ **Expected Output**
```json
{
  "setup": "Woodpecker",
  "punchline": "Woodpecker you a joke, but I'm afraid it might be too 'hole-some'!",
  "rating": 7
}
```
📌 **Explanation:**  
- The system message defines how the AI should respond by providing past examples.  
- The model learns the joke structure from the few-shot examples.  
- When we ask it for a joke about "woodpeckers," it follows the pattern and returns a structured response.  

---

# 🛠 **2. Few-Shot Prompting with Tool Calling**  

In some AI models, responses are structured using **tool calling**, meaning the AI generates tool calls instead of plain text. We can provide few-shot examples as **explicit tool calls** to guide the response.  

### 📜 **Code Example**
```python
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage

# Define few-shot examples using Tool Calls
examples = [
    HumanMessage("Tell me a joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Why don't planes ever get tired?",
                    "punchline": "Because they have rest wings!",
                    "rating": 2,
                },
                "id": "1",
            }
        ],
    ),
    ToolMessage("", tool_call_id="1"),
    HumanMessage("Tell me another joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Cargo",
                    "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!",
                    "rating": 10,
                },
                "id": "2",
            }
        ],
    ),
    ToolMessage("", tool_call_id="2"),
]

# Define the system prompt
system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke with a setup and punchline."""

prompt = ChatPromptTemplate.from_messages(
    [("system", system), ("placeholder", "{examples}"), ("human", "{input}")]
)

few_shot_structured_llm = prompt | structured_llm
result = few_shot_structured_llm.invoke({"input": "crocodiles", "examples": examples})

print(result)
```

### ✅ **Expected Output**
```json
{
  "setup": "Crocodile",
  "punchline": "Crocodile be seeing you later, alligator!",
  "rating": 6
}
```
📌 **Explanation:**  
- The AI uses **previously defined tool calls** to generate structured responses.  
- This method is useful when integrating AI with APIs or structured data systems.  
- The model recognizes patterns in past examples and adapts its output.  

---

# 🌎 **Real-World Applications of Few-Shot Prompting**  

Few-shot prompting is widely used in various fields to improve AI performance. Here are a few real-world applications:  

### 🎙️ **1. Chatbots & Virtual Assistants**  
🔹 AI assistants like **ChatGPT, Alexa, and Google Assistant** use few-shot prompting to generate responses in structured formats, ensuring consistency in answering FAQs or customer queries.  

### 🛍️ **2. E-commerce Product Descriptions**  
🔹 AI-powered e-commerce platforms use few-shot prompting to **generate structured product descriptions** based on past examples, ensuring a consistent tone and format.  

### 🏦 **3. Financial Data Extraction**  
🔹 In banking, AI models extract and format financial data (e.g., **loan applications, transaction summaries**) using few-shot prompting to maintain consistency and accuracy.  

### 🎨 **4. Creative Writing & Storytelling**  
🔹 AI tools like


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

---
Got it! I'll break down the concept of **Tool Calling Agents** in an easy-to-understand way, using detailed explanations, real-world applications, code examples, and step-by-step breakdowns.  

---

# 🔥 Understanding Tool Calling Agents in AI  
In modern AI-powered applications, **Tool Calling Agents** help language models (LLMs) interact with external tools and make multi-step decisions to solve complex tasks. This architecture expands the capability of LLMs beyond simple text-based responses.  

---

## 🧠 Why Use Tool Calling Agents?  
### 🔹 Traditional LLM Limitations  
- Basic LLMs only generate responses based on text inputs.  
- They lack memory, planning, and the ability to interact with external tools.  

### 🔹 Enhanced Capabilities with Tool Calling  
✅ **Multi-step decision-making** – The AI doesn't just return an answer but takes actions in sequence.  
✅ **Tool access** – The AI can fetch data from APIs, databases, or external functions.  
✅ **Memory retention** – The AI remembers past interactions within a conversation.  
✅ **Planning** – The AI breaks a complex task into smaller steps.  

### 📌 **Real-World Example**  
Imagine you have an **AI-powered assistant** for booking flights:  
1. It first asks for your **travel destination and dates**.  
2. It **calls a flight search API** to find available options.  
3. It **fetches weather data** for your destination.  
4. It then **summarizes everything** for you in a human-readable format.  

This is an example of how **Tool Calling Agents** allow AI to **think and act dynamically** rather than just responding with static text.  

---

# 🚀 ReAct: A Powerful Agent Architecture  
**ReAct (Reasoning + Acting)** is a powerful architecture that combines reasoning and action-taking by AI. It consists of:  

1️⃣ **Tool Calling** – The AI decides when to use external tools.  
2️⃣ **Memory** – It remembers previous steps in a multi-step process.  
3️⃣ **Planning** – It plans its actions dynamically.  

🔹 ReAct agents allow for more complex AI behaviors, making them **interactive and intelligent problem solvers**.  

---

# 🏗️ Implementing a Tool Calling Agent  

We’ll use **LangChain** to implement a **Tool Calling Agent** using `create_react_agent`.  

## 🔹 **Step 1: Install Dependencies**  
Before starting, install the necessary Python libraries:  
```bash
pip install langchain langchain-openai
```  

## 🔹 **Step 2: Import Required Libraries**  
```python
from datetime import datetime
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent
```  

### 🔹 **Step 3: Define a Tool (Function) for the AI to Use**  
Here, we define a simple **weather-checking tool** that the AI can call when needed:  
```python
def check_weather(location: str, at_time: datetime | None = None) -> str:
    """Return the weather forecast for the specified location."""
    return f"It's always sunny in {location}"
```  
📝 **Explanation:**  
- This function **simulates** a weather API by always returning **"It's always sunny"**.  
- The AI will call this function whenever it needs weather data.  

---

### 🔹 **Step 4: Create the AI Model & Tool Calling Agent**  
```python
tools = [check_weather]  # List of tools the AI can use
model = ChatOpenAI(model="gpt-4o")  # GPT-4 AI model

# Create the Tool Calling Agent
graph = create_react_agent(model, tools=tools)
```  
📝 **Explanation:**  
- We **define a list of tools** that the AI can call.  
- We create a **GPT-4 AI model** (`ChatOpenAI`).  
- The `create_react_agent` function connects the AI with tools, enabling tool calling.  

---

### 🔹 **Step 5: Give Input to the AI**  
```python
inputs = {"messages": [("user", "what is the weather in San Francisco?")]}  

# Process the input through the AI agent
for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]  # Get the last message
    if isinstance(message, tuple):
        print(message)
    else:
        message.pretty_print()
```  

📝 **Explanation:**  
1️⃣ **User asks for the weather in San Francisco.**  
2️⃣ The AI detects that it needs weather data and **calls the `check_weather` tool**.  
3️⃣ The AI **retrieves the result** and presents it to the user.  

### 🔹 **Expected Output**  
```
User: What is the weather in San Francisco?
================================== AI Message ==================================
Tool Calls:
check_weather (call_123XYZ)
Call ID: call_123XYZ
Args:
    location: San Francisco
================================= Tool Message =================================
Name: check_weather
It's always sunny in San Francisco
================================== AI Message ==================================
The weather in San Francisco is sunny.
```

---

# 🎯 Enhancing AI with System Prompts  
We can customize the AI's personality using a **system prompt**:  

```python
system_prompt = "You are a helpful bot named Fred."
graph = create_react_agent(model, tools, prompt=system_prompt)

inputs = {"messages": [("user", "What's your name? And what's the weather in SF?")]}  

for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]
    if isinstance(message, tuple):
        print(message)
    else:
        message.pretty_print()
```  

✅ **Now, the AI introduces itself as "Fred" before providing weather updates!**  

---

# 🔥 Advanced Use Case: AI with Custom Planning  
We can define a **more advanced AI agent** that includes planning logic:  

```python
from langchain_core.prompts import ChatPromptTemplate

# Define a structured conversation flow
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a polite and helpful assistant."),
    ("placeholder", "{messages}"),
    ("user", "Always remember to respond in a friendly manner."),
])

# Create AI Agent with a structured prompt
graph = create_react_agent(model, tools, prompt=prompt)
inputs = {"messages": [("user", "What's your name? And what's the weather in SF?")]}  

for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]
    if isinstance(message, tuple):
        print(message)
    else:
        message.pretty_print()
```

---

# 🎯 Key Takeaways  
🔹 **Tool Calling Agents** enable AI to interact with external tools dynamically.  
🔹 **ReAct Architecture** allows AI to **plan, reason, and act** in multiple steps.  
🔹 **Real-World Applications** include AI assistants, automation bots, and data retrieval systems.  
🔹 **LangChain's `create_react_agent`** makes it easy to build powerful AI agents.  

🚀 **Now, you can build your own AI assistants that interact with the real world!** 🎉  

Would you like to extend this with **API integration** or **memory retention**? 😊

---
Got it! I'll break this down in a detailed, beginner-friendly way with real-world applications, code examples, and explanations of each line.  

---

# 🛠️ **Understanding ToolNode in LangChain**  

## 📌 **What is ToolNode?**  
ToolNode is a special node in **LangGraph** that executes tools based on the last AI-generated message. If multiple tool calls are made, ToolNode runs them in **parallel** and returns their results.  

Think of **ToolNode** as a **function dispatcher** that picks the correct function (tool) based on the AI's request and runs it automatically.

### 🔹 **Real-World Use Case**  
🔸 **Chatbots with Actions**: Suppose you create an AI assistant for booking flights, checking weather, or setting reminders. The AI needs to call different tools (functions) based on user requests. **ToolNode** ensures the correct function is called.  

---

## ⚙️ **Key Features of ToolNode**  

### ✅ **Runs Tools in Parallel**  
If multiple tools are called, they run **simultaneously**, reducing wait time.  

### ✅ **Error Handling**  
Handles tool errors gracefully instead of crashing the system.  

### ✅ **State and Store Injection**  
Automatically passes necessary **context (state & store)** to tools when needed.

---

## 🖥️ **Basic Example: Running Tools with ToolNode**  

Let's say we have **two tools**:  
1️⃣ A tool that **adds** two numbers.  
2️⃣ A tool that **multiplies** two numbers.

🔹 **Step 1: Import necessary modules**
```python
from typing import List
from langchain_core.tools import tool
from langgraph.prebuilt import ToolNode
```
👉 **Explanation**:  
- `tool` → Used to define **custom tools (functions)** that can be called.  
- `ToolNode` → Executes tools based on AI requests.

---

🔹 **Step 2: Define Tools (Functions)**  
```python
@tool
def add_numbers(a: int, b: int) -> int:
    """Adds two numbers."""
    return a + b

@tool
def multiply_numbers(a: int, b: int) -> int:
    """Multiplies two numbers."""
    return a * b
```
👉 **Explanation**:  
- The `@tool` decorator tells **LangGraph** that these functions are **tools**.  
- Each function takes two numbers as input and returns a result.  

---

🔹 **Step 3: Create a ToolNode**  
```python
node = ToolNode([add_numbers, multiply_numbers])
```
👉 **Explanation**:  
- `ToolNode([add_numbers, multiply_numbers])` → Registers both tools so they can be called dynamically.

---

🔹 **Step 4: Create Tool Calls (AI Requests)**  
```python
tool_call1 = {"name": "add_numbers", "args": {"a": 5, "b": 3}, "id": "1", "type": "tool_call"}
tool_call2 = {"name": "multiply_numbers", "args": {"a": 4, "b": 2}, "id": "2", "type": "tool_call"}
```
👉 **Explanation**:  
- Each tool call represents an **AI request** to call a tool.  
- `"name"` → Specifies which tool to use.  
- `"args"` → The input values for the tool.  
- `"id"` → Unique identifier for each tool call.

---

🔹 **Step 5: Invoke the Tools with ToolNode**  
```python
state = {
    "messages": [{"tool_calls": [tool_call1, tool_call2]}]
}

result = node.invoke(state)
print(result)
```
👉 **Explanation**:  
- `"messages"` stores **AI-generated tool calls**.  
- `node.invoke(state)` → Executes the tools and returns their results.

---

### 🎯 **Expected Output**
```python
[
    {'content': '8', 'name': 'add_numbers', 'tool_call_id': '1'},
    {'content': '8', 'name': 'multiply_numbers', 'tool_call_id': '2'}
]
```
👉 **Explanation**:  
- The **add tool** (5+3) returns `8`.  
- The **multiply tool** (4×2) also returns `8`.  

✅ **ToolNode correctly executed both tools in parallel!**  

---

## 🏆 **Advanced Feature: Injected State**  
Sometimes, tools need **context** (previous messages, user data). **InjectedState** allows tools to access **global state**.

### 🔹 **Example: Using InjectedState**
```python
from typing_extensions import Annotated
from langgraph.prebuilt import InjectedState

@tool
def personalized_greeting(name: str, state: Annotated[dict, InjectedState]) -> str:
    """Creates a personalized greeting based on user history."""
    if "greeted" in state:
        return f"Welcome back, {name}!"
    else:
        return f"Hello, {name}!"
```
👉 **Explanation**:  
- `state: Annotated[dict, InjectedState]` → Injects the **conversation history** into the tool.  
- If the user has been **greeted before**, it **remembers** and provides a more personalized greeting.

---

## 🔥 **Real-World Use Cases of ToolNode**  

| 🌍 Use Case  | 📌 Example |
|-------------|-----------|
| Chatbots with tools | AI assistant booking flights, setting reminders |
| Financial apps | Fetching bank details, calculating interest |
| E-commerce | Checking order status, recommending products |
| AI Support Agents | Automatically answering FAQs using tools |

---

## 📌 **Conclusion**  
✅ **ToolNode** is a **powerful feature** in LangGraph that allows **AI to call tools dynamically**.  
✅ It enables **parallel execution**, **error handling**, and **context injection**.  
✅ It is widely used in **chatbots, automation, and AI-powered applications**.

Would you like me to explain any part further? 😊

---
# 🔧 **Understanding ToolNode in LangGraph: A Deep Dive**  

## 📌 **Introduction to ToolNode**  
`ToolNode` is a key component in `langgraph`, a framework built on **LangChain**, enabling structured workflows for AI agents. It serves as a **runnable node** that executes **tools** (functions, API calls, etc.) when an AI-generated message requests them.

## 🎯 **Purpose of ToolNode**  
- Executes **tool calls** from AI messages.  
- Handles multiple tools **in parallel** if needed.  
- Supports error handling for tools.  
- Passes required **state** and **store** to tools automatically.  
- Works in **StateGraph** and **MessageGraph** for structured AI workflows.  

---

## 🛠️ **Key Parameters of ToolNode (Explained with Examples)**  

### 1️⃣ **tools** (List of callable tools)  
This is a list of tools that `ToolNode` can execute. Tools can be either:  
✅ **Functions** (Python functions performing a task).  
✅ **LangChain Tools** (Predefined tools in LangChain).  

🔹 **Example:**  
```python
from langchain_core.tools import tool
from langgraph.prebuilt import ToolNode

@tool
def add_numbers(a: int, b: int) -> int:
    """Returns the sum of two numbers."""
    return a + b

node = ToolNode([add_numbers])
```
👉 **Real-world Use Case:**  
An AI-powered **calculator chatbot** that performs arithmetic when the user asks for calculations.

---

### 2️⃣ **name** (Name of the ToolNode)  
Defines the **identifier** for this node in a workflow. Default is `"tools"`.  

🔹 **Example:**  
```python
node = ToolNode([add_numbers], name="calculator_node")
```
👉 **Why?**  
Useful when multiple `ToolNode`s exist, such as `"math_tools"`, `"weather_tools"`, etc.

---

### 3️⃣ **handle_tool_errors** (Error Handling Strategy)  
Controls **what happens** when a tool fails.  

| Value Type | Behavior |
|------------|----------|
| `True` (default) | Catches all errors and returns a default error message. |
| `str` | Returns a custom error message. |
| `tuple[type[Exception], ...]` | Catches only specific exceptions. |
| `Callable[..., str]` | Uses a function to generate an error message. |
| `False` | Lets the error propagate normally. |

🔹 **Example (Handling Errors Gracefully):**  
```python
def custom_error_handler(error):
    return f"Oops! Something went wrong: {str(error)}"

node = ToolNode([add_numbers], handle_tool_errors=custom_error_handler)
```
👉 **Real-world Use Case:**  
A **customer support chatbot** handling API failures and returning a friendly message.

---

### 4️⃣ **messages_key** (Key for Messages in Input State)  
Defines where `ToolNode` should look for **tool call messages**.  

🔹 **Example:**  
```python
node = ToolNode([add_numbers], messages_key="user_requests")
```
👉 **Why?**  
Useful when your workflow **stores messages in a custom key** instead of `"messages"`.

---

## 🚀 **How ToolNode Works (Step-by-Step with Code)**  

🔹 **1. Define Tools**  
```python
from langchain_core.tools import tool

@tool
def greet_user(name: str) -> str:
    return f"Hello, {name}!"

@tool
def square_number(x: int) -> int:
    return x * x
```
🔹 **2. Create a ToolNode**  
```python
from langgraph.prebuilt import ToolNode

node = ToolNode([greet_user, square_number])
```
🔹 **3. Create a Tool Call State and Invoke the Node**  
```python
from langchain_core.messages import AIMessage, ToolMessage

tool_call1 = {"name": "greet_user", "args": {"name": "Alice"}, "id": "1", "type": "tool_call"}
tool_call2 = {"name": "square_number", "args": {"x": 4}, "id": "2", "type": "tool_call"}

state = {"messages": [AIMessage("", tool_calls=[tool_call1, tool_call2])]}
result = node.invoke(state)
print(result)
```
**🔹 Output:**  
```json
[
    ToolMessage(content="Hello, Alice!", name="greet_user", tool_call_id="1"),
    ToolMessage(content="16", name="square_number", tool_call_id="2")
]
```
👉 **Real-world Use Case:**  
This is how **AI virtual assistants** can call different functions (like greeting a user and performing calculations) dynamically.

---

## 🧩 **Advanced Concepts: Injecting State and Store**  

### 🏷️ **InjectedState: Passing Dynamic Data to Tools**  
- `InjectedState` allows **tools to access the graph's state** automatically.  
- The AI model **does not generate these arguments**; they are filled by the system.  

🔹 **Example (Accessing Conversation History)**  
```python
from typing import List
from langgraph.prebuilt import InjectedState
from typing_extensions import Annotated

@tool
def chat_tool(user_input: str, history: Annotated[List[str], InjectedState("messages")]) -> str:
    return f"Previous messages: {history}. New input: {user_input}"

node = ToolNode([chat_tool])
```
👉 **Real-world Use Case:**  
**Chatbots remembering past messages** in a conversation.

---

### 🏷️ **InjectedStore: Accessing External Data**  
- `InjectedStore` enables **fetching data** from a memory store.  
- Useful for **retrieving persistent values**.  

🔹 **Example (Fetching Data from Memory)**  
```python
from langgraph.store.memory import InMemoryStore
from langgraph.prebuilt import InjectedStore

store = InMemoryStore()
store.put(("config",), "user_settings", {"theme": "dark"})

@tool
def get_theme(my_store: Annotated[dict, InjectedStore()]) -> str:
    return my_store.get(("config",), "user_settings")["theme"]

node = ToolNode([get_theme])
```
👉 **Real-world Use Case:**  
Personalized AI assistants that remember **user preferences**.

---

## 📌 **Alternative Approaches Without ToolNode**  

🔹 **1. Using Simple Python Functions**  
```python
def add_numbers(a, b):
    return a + b
print(add_numbers(3, 5))  # Output: 8
```
❌ **Limitation:** No structured workflow for AI agents.

---

🔹 **2. Using Traditional APIs**  
```python
import requests

def fetch_weather(city):
    response = requests.get(f"https://api.weather.com/{city}")
    return response.json()
```
❌ **Limitation:** Manually handling **state injection**.

---

🔹 **3. Using LangChain Agents**  
```python
from langchain.agents import initialize_agent

agent = initialize_agent([add_numbers], ...)
```
❌ **Limitation:** Less **structured** than `ToolNode` for multi-tool workflows.

---

## 🎯 **Final Thoughts: When to Use ToolNode?**  
✅ When you need **AI-driven workflows** that invoke tools dynamically.  
✅ When your tools **rely on external state or memory**.  
✅ When you need **error handling and structured execution**.  
✅ When working with **complex AI assistants requiring multiple tools**.  

🔹 **Real-world Example:**  
A **customer service bot** using `ToolNode` to:  
- Fetch **order details** from a database.  
- Provide **support ticket updates**.  
- Process **returns and refunds** dynamically.

---

## 🏆 **Summary Table**  

| Feature | ToolNode | Regular Functions | LangChain Agents |
|---------|---------|------------------|----------------|
| **AI Workflow Support** | ✅ Yes | ❌ No | ✅ Yes |
| **Parallel Execution** | ✅ Yes | ❌ No | ✅ Yes |
| **Error Handling** | ✅ Built-in | ❌ Manual | ✅ Built-in |
| **State Injection** | ✅ Yes | ❌ No | ❌ No |
| **Memory Store Integration** | ✅ Yes | ❌ No | ❌ No |

---

## 🔥 **Next Steps**  
- ✅ Try implementing a **ToolNode workflow** in a chatbot.  
- ✅ Experiment with **InjectedState** and **InjectedStore**.  
- ✅ Optimize **error handling** in your AI agents.  

Would you like to see more real-world case studies? 🚀

---
# 🔍 **Understanding `ValidationNode` in Depth**  

The `ValidationNode` is a component in `langgraph` that ensures AI tool calls conform to predefined schemas. It does **not** execute the tools but validates them, making it crucial for structured output generation in AI-powered workflows.  

Let's break this down step by step for a **beginner-friendly** explanation.  

---

## 📌 **What is `ValidationNode`?**  

A `ValidationNode` is a **validation checkpoint** in an AI conversation workflow. It ensures that all tool requests generated by an AI message are **correct** before proceeding.  

🔹 **Why is this important?**  
- AI models may generate incorrect or malformed tool calls.  
- Helps prevent invalid requests from reaching external tools.  
- Ensures data conforms to a strict schema before being used.  

---

## 🛠 **How `ValidationNode` Works?**  

It is used in **StateGraph** or **MessageGraph** frameworks for structured AI workflows.  

🔹 **Key Features:**  
✔️ Validates AI tool calls **before** execution.  
✔️ Prevents invalid requests from propagating.  
✔️ Allows **re-prompting** the AI to generate valid responses.  
✔️ Supports **custom error formatting**.  

🔹 **It does NOT:**  
❌ Execute the tools.  
❌ Modify the original AI messages.  

---

## 📌 **Parameters of `ValidationNode`**  

### 1️⃣ **Schemas (`schemas`)**  
A list of schemas to validate the AI tool calls. These can be:  
✅ `pydantic.BaseModel` (validates structured data).  
✅ `BaseTool` (validates a tool’s expected parameters).  
✅ A function (automatically derives a schema from function parameters).  

🔹 **Example:**  
```python
from pydantic import BaseModel, validator

class SelectNumber(BaseModel):
    a: int

    @validator("a")
    def a_must_be_meaningful(cls, v):
        if v != 37:
            raise ValueError("Only 37 is allowed")
        return v
```
Here, the schema ensures that **only the number 37 is accepted**.  

---

### 2️⃣ **Custom Error Formatting (`format_error`)**  
Allows custom formatting of validation errors.  

🔹 **Example:**  
```python
def custom_error_formatter(exception, tool_call, schema):
    return f"Validation failed for {tool_call.name}: {exception}"
```

---

### 3️⃣ **Node Name (`name`)**  
Default: `'validation'`  
Used to **identify the node** in the workflow.  

---

### 4️⃣ **Tags (`tags`)**  
Optional metadata tags for organization.  

🔹 **Example:**  
```python
ValidationNode([SelectNumber], tags=["number-validation"])
```

---

## 🖥 **Code Example: Using `ValidationNode` in a StateGraph**  

```python
from typing import Literal, Annotated
from typing_extensions import TypedDict
from pydantic import BaseModel, validator
from langchain_anthropic import ChatAnthropic
from langgraph.graph import END, START, StateGraph
from langgraph.prebuilt import ValidationNode
from langgraph.graph.message import add_messages

# Define a schema
class SelectNumber(BaseModel):
    a: int

    @validator("a")
    def a_must_be_meaningful(cls, v):
        if v != 37:
            raise ValueError("Only 37 is allowed")
        return v

# Define state
class State(TypedDict):
    messages: Annotated[list, add_messages]

# Create the graph
builder = StateGraph(State)

# Add AI model
llm = ChatAnthropic(model="claude-3-haiku-20240307").bind_tools([SelectNumber])
builder.add_node("model", llm)

# Add validation node
builder.add_node("validation", ValidationNode([SelectNumber]))

# Define workflow edges
builder.add_edge(START, "model")

# Validation logic
def should_validate(state: list) -> Literal["validation", "__end__"]:
    if state[-1].tool_calls:
        return "validation"
    return END

builder.add_conditional_edges("model", should_validate)

# Retry logic if validation fails
def should_reprompt(state: list) -> Literal["model", "__end__"]:
    for msg in state[::-1]:
        if msg.type == "ai":
            return END
        if msg.additional_kwargs.get("is_error"):
            return "model"
    return END

builder.add_conditional_edges("validation", should_reprompt)

# Compile the graph
graph = builder.compile()

# Invoke the AI model
res = graph.invoke(("user", "Select a number, any number"))

# Print the results
for msg in res:
    msg.pretty_print()
```

---

## 🔥 **Real-World Use Cases**  

### 📌 1️⃣ **Chatbot Validation**  
A chatbot integrated with external APIs (e.g., weather data) **must ensure** that the API requests are valid before calling external services.  

🔹 **Example:**  
- User asks: *"Get weather for Paris"*  
- AI generates an API request `{ "city": "Paris" }`  
- `ValidationNode` checks if `"city"` is a required field.  

---

### 📌 2️⃣ **E-Commerce Order Processing**  
Before submitting an order, `ValidationNode` ensures:  
✔️ All required fields (product ID, quantity, address) are present.  
✔️ Values are **correctly formatted** (e.g., email validation).  

🔹 **Example:**  
```python
class Order(BaseModel):
    product_id: str
    quantity: int

    @validator("quantity")
    def check_quantity(cls, v):
        if v <= 0:
            raise ValueError("Quantity must be greater than 0")
        return v
```

---

### 📌 3️⃣ **Healthcare Data Validation**  
When an AI-powered system processes **patient data**, validation ensures:  
✔️ Date of birth is in correct format.  
✔️ Medical test results have **valid ranges**.  

🔹 **Example:**  
```python
class PatientData(BaseModel):
    age: int

    @validator("age")
    def check_age(cls, v):
        if v < 0 or v > 120:
            raise ValueError("Invalid age range")
        return v
```

---

## 🔄 **Alternative Approaches**  

If you don’t want to use `ValidationNode`, here are **three alternatives**:  

### ✅ **1️⃣ Use Manual Validation in Python**  
Instead of `ValidationNode`, manually validate data **before** using it.  

🔹 **Example:**  
```python
def validate_input(data):
    if not isinstance(data["a"], int):
        raise ValueError("Invalid input: must be an integer")
    return data
```

---

### ✅ **2️⃣ Use `pydantic` Validation Directly**  
Instead of `ValidationNode`, use **standalone `pydantic` models**.  

🔹 **Example:**  
```python
try:
    valid_data = SelectNumber(a=42)  # Raises error
except ValueError as e:
    print(f"Validation failed: {e}")
```

---

### ✅ **3️⃣ Use Schema Validation with JSON Schema**  
Use JSON schema for validation before sending data to external tools.  

🔹 **Example:**  
```json
{
  "type": "object",
  "properties": {
    "a": { "type": "integer", "minimum": 1 }
  },
  "required": ["a"]
}
```

---

## 🎯 **Key Takeaways**  

✔️ `ValidationNode` **ensures AI tool calls are valid** before execution.  
✔️ Works with **StateGraph** and **MessageGraph**.  
✔️ Supports **pydantic models, functions, and custom errors**.  
✔️ Used in **chatbots, APIs, e-commerce, and healthcare** for structured AI workflows.  
✔️ **Alternatives:** Manual validation, `pydantic`, JSON schema.  

---

## ❓ **Got Questions?**  
Let me know if you need further clarifications or more examples! 🚀

---
# 🛠️ **Understanding Tool Calling, Memory, and Planning in AI Agents**  

AI agents often need to interact with external systems, remember past interactions, and make decisions dynamically. This article explains **Tool Calling, Memory, and Planning**—key concepts that enable AI models to function effectively in real-world applications.

---

## 📌 **1. Tool Calling in AI Agents**  

### 🔹 **What is Tool Calling?**  
Tool calling allows an AI agent (e.g., an LLM like GPT) to **interact with external systems** such as APIs, databases, or web services. Since external systems require structured inputs, the AI model needs a way to format its output properly. Tool calling helps the AI:  

✅ **Understand API input requirements**  
✅ **Choose the right tool based on user input**  
✅ **Return a structured response**  

### 🔹 **How It Works**  
1️⃣ The AI receives a natural language input (e.g., *"What’s the weather in New York?"*).  
2️⃣ It recognizes that calling a weather API is needed.  
3️⃣ It formats the request properly (e.g., `{"city": "New York", "unit": "Celsius"}`).  
4️⃣ The tool (API) processes the request and returns the data.  
5️⃣ The AI then presents this response back to the user in a human-readable format.  

### 🖥 **Example Code (Using LangChain in Python)**  
```python
from langchain.chat_models import ChatOpenAI

# Define an external function (e.g., API call)
def get_weather(city: str):
    return f"The weather in {city} is 22°C."

# Bind the function as a tool
llm = ChatOpenAI(model="gpt-4").bind_tools([get_weather])

# AI can now call the get_weather function when needed
response = llm.invoke("What's the weather in Karachi?")
print(response)
```
🟢 **Real-World Example:**  
🔹 AI-powered customer service bots use tool calling to fetch order details from a database when users ask, *"Where is my order?"*.  

---

## 🧠 **2. Memory in AI Agents**  

### 🔹 **What is Memory?**  
Memory allows AI agents to **retain information across multiple interactions**, making them smarter and more context-aware.  

### 🔹 **Types of Memory:**  
1️⃣ **Short-term Memory** - Keeps recent conversation history (e.g., the last few messages).  
2️⃣ **Long-term Memory** - Stores data across multiple interactions, so the AI "remembers" past conversations.  

### 🔹 **How Memory Works in AI**  
- Memory ensures an agent does not lose track of the conversation.  
- It can store structured data, such as user preferences and past queries.  

### 🖥 **Example Code (Using LangChain Memory)**  
```python
from langchain.memory import ConversationBufferMemory

# Initialize memory
memory = ConversationBufferMemory()

# Store conversation history
memory.save_context({"user": "Tell me a joke"}, {"ai": "Why don't scientists trust atoms? Because they make up everything!"})

# Retrieve stored memory
print(memory.load_memory_variables({}))
```

🟢 **Real-World Example:**  
🔹 Virtual assistants like Alexa or Google Assistant use memory to remember user preferences, e.g., *"Remind me to buy groceries every Sunday."*  

---

## 🏗️ **3. Planning in AI Agents**  

### 🔹 **What is Planning?**  
Planning allows an AI agent to decide **which actions to take next**, making it capable of handling complex, multi-step tasks.  

### 🔹 **ReAct Architecture (Reasoning + Acting)**  
- The AI loops through **decision-making steps** until the goal is achieved.  
- It **decides which tools to call** and **processes tool outputs** before making further decisions.  

### 🔹 **How Planning Works**  
1️⃣ The AI gets user input (e.g., *"Find a restaurant and book a table for me."*).  
2️⃣ It **calls a restaurant API** to get a list of available options.  
3️⃣ It **asks the user for preferences** (e.g., cuisine, budget).  
4️⃣ It **calls the booking API** and confirms the reservation.  

### 🖥 **Example Code (Using ReAct Planning in LangChain)**  
```python
from langchain.tools import Tool

# Define two tools
def find_restaurant(location: str):
    return f"Top-rated restaurant in {location}: The Food Spot"

def book_table(restaurant: str):
    return f"Table booked at {restaurant}!"

# Planning agent
tools = [Tool(name="find_restaurant", func=find_restaurant), Tool(name="book_table", func=book_table)]

# Example of planning flow
restaurant = find_restaurant("New York")
confirmation = book_table(restaurant)
print(confirmation)
```

🟢 **Real-World Example:**  
🔹 AI travel agents like Expedia’s chatbot use planning to **book flights, hotels, and restaurants** based on user preferences.

---

# 🎯 **Conclusion**  

✅ **Tool Calling**: Enables AI to interact with external APIs and services.  
✅ **Memory**: Helps AI agents retain context across conversations.  
✅ **Planning**: Allows AI to make multi-step decisions dynamically.  

These features **make AI agents smarter, more interactive, and useful in real-world applications** like virtual assistants, chatbots, and automation systems. 🚀

---
# 🤖 **Custom Agent Architectures in LangChain**  

Customizing agent architectures allows for **better performance** on specific tasks compared to standard **tool-calling agents** (like ReAct). LangGraph provides powerful tools to build **tailored AI agent systems**. Let’s explore these concepts in **detail with real-world applications and code examples**.  

---

## 🔍 **1. Why Use Custom Agent Architectures?**  
While **pre-built agents** (e.g., ReAct) work for many applications, **custom architectures** offer:  
✅ **Better control** over decision-making.  
✅ **Optimization** for domain-specific tasks.  
✅ **Increased reliability** with **human oversight** and **parallel execution**.  

**Example Use Cases:**  
- **Customer Support Bots** 🛍️: Human review ensures accurate responses.  
- **Financial Analysis Agents** 📊: Parallel tasks improve speed.  
- **Medical Diagnosis Assistants** 🏥: Subgraphs help manage different specialties.  

---

## 👨‍👩‍👦‍👦 **2. Human-in-the-Loop (HITL) in AI Agents**  

### 🔹 **What is Human-in-the-Loop?**  
HITL involves **human intervention** to:  
✔️ Approve **actions** before execution.  
✔️ Provide **feedback** for model improvement.  
✔️ Guide **complex decisions** where automation is risky.  

### 🏢 **Real-World Example:**  
**Loan Approval System** in banks:  
💰 The AI agent evaluates applications based on risk.  
👨‍💼 A human manager **reviews edge cases** before final approval.  

### 🛠 **Implementation:**  
```python
def ai_decision(state):
    if state["risk_score"] > 80:
        return "Needs Human Review"
    else:
        return "Auto-Approved"
```
---

## ⚡ **3. Parallelization for Efficiency**  

### 🔹 **What is Parallelization?**  
Parallelization allows an agent to **execute multiple tasks at the same time** rather than sequentially.  

### 🎯 **Benefits:**  
🚀 **Faster** processing.  
🔄 **Better resource utilization**.  
🔬 **Scalability** for complex workflows.  

### 🏢 **Real-World Example:**  
**E-commerce Price Comparison Agent** 🛒  
- The agent checks **Amazon, eBay, and Walmart** **simultaneously** instead of one by one.  

### 🛠 **Implementation:**  
```python
import concurrent.futures

def fetch_data(site):
    return f"Data from {site}"

sites = ["Amazon", "eBay", "Walmart"]

with concurrent.futures.ThreadPoolExecutor() as executor:
    results = executor.map(fetch_data, sites)

print(list(results))  # ['Data from Amazon', 'Data from eBay', 'Data from Walmart']
```
---

## 🔗 **4. Subgraphs: Modular AI Design**  

### 🔹 **What are Subgraphs?**  
Subgraphs **divide a complex AI system** into **smaller, manageable units**.  

### 🎯 **Benefits:**  
📌 **Encapsulation**: Isolate **state management** for different components.  
📌 **Code Reusability**: Define logic **once** and use it in multiple places.  
📌 **Team Collaboration**: Different teams can work on separate modules independently.  

### 🏢 **Real-World Example:**  
**Automated Customer Service System** 📞  
- A **chatbot subgraph** handles basic queries.  
- A **billing subgraph** manages payments.  
- A **human-agent subgraph** steps in for complex issues.  

### 🛠 **Implementation:**  
```python
from langgraph.graph import StateGraph
from typing import TypedDict

class ParentState(TypedDict):
    query: str

class SubgraphState(TypedDict):
    query: str
    response: str

# Define Subgraph
def chatbot_response(state: SubgraphState):
    return {"response": f"Answer to {state['query']}"}

subgraph_builder = StateGraph(SubgraphState)
subgraph_builder.add_node(chatbot_response)
subgraph = subgraph_builder.compile()

# Define Parent Graph
builder = StateGraph(ParentState)
builder.add_node("Chatbot", subgraph)

graph = builder.compile()
```
---

## 🔄 **5. Reflection: Self-Improving AI**  

### 🔹 **What is Reflection in AI?**  
Reflection helps AI **evaluate its own performance** and **learn from mistakes**.  

### 🎯 **Why is this important?**  
🤖 **Self-correction** improves accuracy.  
📈 **Feedback loops** lead to better decision-making.  
🛠️ Can be **LLM-based** or **deterministic** (e.g., using error logs).  

### 🏢 **Real-World Example:**  
**AI Code Assistant (like GitHub Copilot)** 💻  
- If a **code suggestion fails to compile**, the AI **re-evaluates** and **suggests a fix**.  

### 🛠 **Implementation:**  
```python
def reflect_on_code(error_log):
    if "syntax error" in error_log:
        return "Rewriting with correct syntax..."
    return "Code is fine"

error_message = "Syntax error in line 3"
print(reflect_on_code(error_message))  # "Rewriting with correct syntax..."
```
---

## 🏆 **Final Thoughts: Why Custom Agent Architectures Matter?**  

🔹 **Standard agents** (like ReAct) are useful but not always optimal.  
🔹 **Custom architectures** improve **control, efficiency, and adaptability**.  
🔹 **Key components** like **human-in-the-loop, parallelization, subgraphs, and reflection** make AI agents **more powerful**.  

🚀 **By leveraging these techniques, you can build AI systems that are smarter, faster, and more reliable!**