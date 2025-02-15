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