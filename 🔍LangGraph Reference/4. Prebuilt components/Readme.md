It looks like you want a **detailed, beginner-friendly explanation** of the `create_react_agent` function, including **real-world applications**, **code examples**, and **alternative approaches** to strengthen your understanding.  

I'll break this down into the following sections to make it **clear and visually engaging**:

---

# 🔹 **Understanding `create_react_agent` in LangChain**  

## 📌 **What is `create_react_agent`?**
The `create_react_agent` function is used to create an **AI agent** that can interact with tools using a **chat-based model**. It is a part of **LangChain**, which is a popular framework for working with **Large Language Models (LLMs)** like **OpenAI's GPT**.

### **💡 Real-World Use Cases:**
- **🤖 AI Chatbots:** Creating AI assistants that can use tools like Google Search, APIs, or databases.  
- **📊 Data Analysis Bots:** A bot that can fetch and analyze data using external tools.  
- **💬 Customer Support:** AI-powered customer support that can call APIs to fetch order details, resolve issues, etc.  

---

# 🛠 **How `create_react_agent` Works?**
The `create_react_agent` function is designed to create an AI agent that:  
✅ Uses an **LLM (like GPT-4)** to process user queries.  
✅ Can call **external tools/APIs** to fetch relevant data.  
✅ Supports **structured responses**, **checkpoints**, and **state management**.  

### **🔹 Key Parameters and Their Purpose**
| Parameter | Description |
|-----------|-------------|
| `model` | Defines the **language model** the agent will use (e.g., `gpt-4`). |
| `tools` | A **list of tools** the agent can use (e.g., web search, APIs). |
| `state_schema` | Defines how the **agent's state** is stored. |
| `prompt` | The **instruction or system message** for the AI agent. |
| `response_format` | Defines how the **AI's output should be structured** (e.g., JSON). |
| `checkpointer` | Saves the **state of the conversation** for continuity. |
| `store` | Used for **storing data across multiple interactions**. |
| `debug` | Enables **debug mode** for logging insights. |

---

# 📝 **Example 1: Basic AI Agent with LangChain**
Let's create a **simple AI agent** using `create_react_agent` that can interact with a **calculator tool**.

## 🔹 **Step 1: Install Dependencies**
First, install **LangChain** and **OpenAI**:  
```bash
pip install langchain openai
```

## 🔹 **Step 2: Write the Code**
```python
from langchain.chat_models import ChatOpenAI
from langchain.tools import Tool
from langchain.schema import SystemMessage
from langchain.agents import create_react_agent

# 🔹 Step 1: Define the language model
llm = ChatOpenAI(model="gpt-4", temperature=0)

# 🔹 Step 2: Create a simple calculator tool
def add_numbers(a: int, b: int) -> int:
    return a + b

calculator_tool = Tool(
    name="Calculator",
    func=add_numbers,
    description="Adds two numbers"
)

# 🔹 Step 3: Define the AI Agent
agent = create_react_agent(
    model=llm, 
    tools=[calculator_tool], 
    prompt=SystemMessage(content="You are a helpful AI that can calculate numbers."),
    debug=True
)

# 🔹 Step 4: Run the agent
response = agent.invoke({"messages": [{"role": "user", "content": "What is 10 + 5?"}]})

# 🔹 Step 5: Print the response
print(response)
```

---

## 🔍 **🔹 Code Breakdown (Line by Line Explanation)**
### **1️⃣ Define the LLM Model**
```python
llm = ChatOpenAI(model="gpt-4", temperature=0)
```
- We initialize an **LLM (GPT-4)** with a **temperature of 0** (which means the responses will be deterministic).  

### **2️⃣ Create a Simple Calculator Tool**
```python
def add_numbers(a: int, b: int) -> int:
    return a + b
```
- This is a simple **Python function** that takes **two numbers** and returns their sum.

### **3️⃣ Register the Tool**
```python
calculator_tool = Tool(
    name="Calculator",
    func=add_numbers,
    description="Adds two numbers"
)
```
- We define a **tool** that uses our `add_numbers` function.
- The **agent** can now call this tool to **perform addition**.

### **4️⃣ Create the AI Agent**
```python
agent = create_react_agent(
    model=llm, 
    tools=[calculator_tool], 
    prompt=SystemMessage(content="You are a helpful AI that can calculate numbers."),
    debug=True
)
```
- We create an **AI agent** that:
  - Uses **GPT-4** (`model=llm`)
  - Can **call the calculator tool**
  - Has a **prompt** telling it to perform calculations
  - Enables **debug mode** to log details

### **5️⃣ Run the Agent**
```python
response = agent.invoke({"messages": [{"role": "user", "content": "What is 10 + 5?"}]})
```
- The **agent receives a query** (`"What is 10 + 5?"`) and **calls the calculator tool**.

---

# 🚀 **Alternative 3 Examples for Stronger Understanding**

### **🔹 Example 2: AI Agent for Web Searching**
Instead of a calculator, let's create an agent that can **search the web** using SerpAPI.  
```python
from langchain.tools import Tool
from langchain.chat_models import ChatOpenAI
from langchain.agents import create_react_agent

def search_google(query: str):
    return f"Results for '{query}' (pretend this is from Google)"

search_tool = Tool(name="GoogleSearch", func=search_google, description="Searches Google for information.")

llm = ChatOpenAI(model="gpt-4", temperature=0)

agent = create_react_agent(model=llm, tools=[search_tool])

response = agent.invoke({"messages": [{"role": "user", "content": "Who is the president of the USA?"}]})

print(response)
```
- This agent can **search Google** for answers using a custom function.

---

### **🔹 Example 3: AI Assistant with Multiple Tools**
An AI that can **search Google AND do calculations**:
```python
tools = [search_tool, calculator_tool]
agent = create_react_agent(model=llm, tools=tools)
```
- This AI can **both search the web** and **perform calculations**.

---

### **🔹 Example 4: AI with Structured Response**
If you want to enforce a **specific response format**:
```python
from langchain.output_parsers import StructuredResponseSchema
response_format = StructuredResponseSchema({"result": str})

agent = create_react_agent(model=llm, tools=[calculator_tool], response_format=response_format)
```
- This ensures that the **AI output is always structured** as a dictionary.

---

# 🏁 **Conclusion**
✅ `create_react_agent` allows us to **build AI-powered agents** that can **call external tools**.  
✅ It is useful for **AI assistants, customer support, and data analysis bots**.  
✅ We can integrate **multiple tools** and **structured responses** for better output.  

---

# 💡 **Next Steps**
- Try **integrating an API tool** (like fetching stock prices).  
- Experiment with **different prompts and response formats**.  
- Deploy this agent in **a real-world app** (e.g., chatbot, data bot).  

---

Would you like me to help with **deploying this in a real project**? 🚀😊

---


## 🔥 **Deep Dive into LangChain's CompiledGraph for AI Agents**
LangChain's **CompiledGraph** is a powerful way to create AI agents that interact with users and external tools in a structured manner. Let's break it down step by step, explain its core logic, and explore real-world applications.

---

# 🧠 **1. What is a CompiledGraph?**
A **CompiledGraph** is a runnable graph structure in LangChain that allows AI models to **interact with external tools** dynamically. It follows a loop where:
1. **User provides input** (e.g., asks a question).
2. **Agent (LLM) processes the request** and checks if external tools are needed.
3. If needed, **Tools are called** (e.g., fetching weather, searching Google, querying databases).
4. The **Agent uses tool responses** and processes further.
5. The **final response is sent to the user**.

This continues **until no more tool calls are required**.

### 🏢 **Real-World Use Cases**
- **AI Chatbots** that answer queries using external APIs (weather, stock prices, etc.).
- **Customer Support Agents** that retrieve account information dynamically.
- **Automated Research Assistants** that query different sources to fetch data.

---

# 🔁 **2. Understanding the Execution Flow**
### 📌 **Flowchart of Execution**
```
User Input → Agent (LLM) → Tools (if needed) → Agent → Response
                         ↑      ↓
                      Call Tools → Process Tool Responses
```

### ✅ **Breakdown of Execution**
1. **User sends a message**.
2. The **Agent (LLM)** processes the input.
3. If tool calls are required, it invokes **external tools**.
4. The **Tools execute their task** (e.g., fetching weather data).
5. The tool responses are **fed back into the Agent**.
6. The **Agent generates the final response** and returns it.

---

# 🚀 **3. Code Example: Simple AI Agent with a Weather Tool**
Let's implement a **LangChain agent** that checks the weather.

### 📝 **Step-by-Step Code Implementation**
```python
# Import necessary modules
from datetime import datetime
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent

# Define a simple tool (weather checker)
def check_weather(location: str, at_time: datetime | None = None) -> str:
    '''Return the weather forecast for the specified location.'''
    return f"It's always sunny in {location}"

# List of tools used by the AI agent
tools = [check_weather]

# Initialize the AI model (GPT-4)
model = ChatOpenAI(model="gpt-4o")

# Create a compiled graph-based AI agent
graph = create_react_agent(model, tools=tools)

# Define user input
inputs = {"messages": [("user", "What is the weather in San Francisco?")]}

# Stream the AI's response
for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]
    if isinstance(message, tuple):
        print(message)  # Print user input
    else:
        message.pretty_print()  # Print AI response
```

### 🔎 **Code Explanation**
1. **Imports**: We import the necessary modules from LangChain.
2. **Weather Tool**: A function `check_weather()` that returns a dummy weather response.
3. **Tools List**: We add our tool to a list (`tools = [check_weather]`).
4. **Model Initialization**: We use `ChatOpenAI(model="gpt-4o")` to define our AI agent.
5. **Agent Creation**: We create the AI agent using `create_react_agent(model, tools=tools)`.
6. **User Input**: We define a dictionary `inputs` that holds user messages.
7. **Processing the Request**: The agent processes the input, calls tools if necessary, and returns a response.

---

# 🎭 **4. Enhancing with a System Prompt**
We can make our AI assistant more human-like by adding a **system prompt**.

### 📌 **Example: Defining a Personality for the AI**
```python
system_prompt = "You are a helpful assistant named Fred."
graph = create_react_agent(model, tools, prompt=system_prompt)

inputs = {"messages": [("user", "What's your name? And what's the weather in SF?")]}

for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]
    if isinstance(message, tuple):
        print(message)
    else:
        message.pretty_print()
```

### 📝 **What This Does**
- Sets up a **system-level personality** for the assistant.
- Ensures that the AI **introduces itself** before answering.
- Allows for **more natural interactions**.

---

# 🎯 **5. Using Advanced Prompts and State Management**
For **complex interactions**, we can add **custom prompts** and track **session states**.

### 🏗 **Example: Adding Date Awareness**
```python
from typing_extensions import TypedDict
from langgraph.managed import IsLastStep
from langchain_core.prompts import ChatPromptTemplate

# Define a chat prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "Today is {today}"),
    ("placeholder", "{messages}"),
])

# Define a custom state structure
class CustomState(TypedDict):
    today: str
    messages: list
    is_last_step: IsLastStep

# Create the AI agent with a custom state
graph = create_react_agent(model, tools, state_schema=CustomState, prompt=prompt)

# Define user input with a specific date
inputs = {
    "messages": [("user", "What's today's date? And what's the weather in SF?")],
    "today": "July 16, 2004"
}

# Stream the AI's response
for s in graph.stream(inputs, stream_mode="values"):
    message = s["messages"][-1]
    if isinstance(message, tuple):
        print(message)
    else:
        message.pretty_print()
```

### 📝 **What This Does**
- The **AI remembers the current date**.
- It **combines past messages** with the new input.
- It ensures **a smooth conversation flow**.

---

# 🏆 **6. Alternative Approaches**
Here are three alternative ways to achieve similar functionality.

### 🅰 **1. Using a Simple Function (Without LangChain)**
```python
def simple_chatbot(user_input):
    if "weather" in user_input.lower():
        return "The weather is sunny!"
    return "I can only check the weather."

print(simple_chatbot("What’s the weather?"))
```
✅ **Pros**: Simple and lightweight  
❌ **Cons**: No AI reasoning, only basic responses  

---

### 🅱 **2. Using OpenAI API Directly**
```python
from openai import OpenAI

client = OpenAI(api_key="your-api-key")

response = client.Completions.create(
    model="gpt-4",
    prompt="What is the weather in San Francisco?",
    max_tokens=50
)
print(response.choices[0].text.strip())
```
✅ **Pros**: Uses GPT-4 directly  
❌ **Cons**: Cannot interact with external tools  

---

### 🅲 **3. Using LangChain Without Graphs**
```python
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate

llm = OpenAI(model_name="gpt-4", temperature=0.5)

prompt = PromptTemplate.from_template("What is the weather in {location}?")

response = llm(prompt.format(location="San Francisco"))
print(response)
```
✅ **Pros**: Uses LangChain for structured responses  
❌ **Cons**: No tool interactions  

---

# 🎯 **Conclusion**
✅ **LangChain’s CompiledGraph** is a powerful way to build interactive AI agents.  
✅ It allows **real-time interactions with external tools**.  
✅ It ensures **dynamic responses using structured execution flows**.  

By mastering this, you can create **intelligent assistants** that **retrieve real-world data** dynamically!

---

💡 **What’s Next?**
- **Try integrating APIs like Google Search, Weather APIs, or databases!**  
- **Experiment with multiple tools** (e.g., Stock Market APIs, Wikipedia Search).  
- **Build your own custom AI assistant** with memory and advanced reasoning! 🚀

---


That’s a lot to cover, but I’ll explain everything in deep detail, with beginner-friendly explanations, real-world use cases, and multiple examples! 

---

# 🧠 Thread-Level & Cross-Thread Memory in AI Agents  

## 🏆 **What Will You Learn?**  
- **What is thread-level memory in AI agents?**  
- **How to implement thread-level and cross-thread memory using `langgraph`?**  
- **Why is memory important in AI assistants?**  
- **Real-world applications of AI memory management.**  
- **Step-by-step explanation of the code.**  
- **Alternative approaches for handling memory in AI agents.**  

---

## 🧩 **What is Memory in AI Agents?**  
When you chat with an AI assistant, you expect it to **remember your previous messages** so it can give **better and more personalized responses.**  
This is where **thread-level and cross-thread memory** comes in!  

### 📌 **Types of Memory in AI Assistants**  
1️⃣ **Thread-Level Memory** 📝  
   - Remembers the chat history **within a single conversation (thread).**  
   - Example: If you ask, *"What's the weather in SF?"* and then follow up with, *"Should I go biking?"*, the AI remembers the context in the same chat thread.  

2️⃣ **Cross-Thread Memory** 🔄  
   - Allows AI to remember user details **across different chat sessions.**  
   - Example: If you talked to an AI yesterday about your name and hobbies, and then today you ask, *"Do you remember me?"*, the AI can recall previous chats!  

---

## 🎯 **Real-World Example: Why AI Memory is Useful?**  
💬 **Customer Support Chatbots**:   
- Customers don’t want to **repeat their issue** every time they start a new chat.   
- A chatbot with memory can **remember past complaints, preferences, and interactions** for better service.  

🤖 **AI Personal Assistants (e.g., ChatGPT, Google Assistant, Alexa)**:  
- If you tell an AI, *"Remind me to buy groceries every Monday,"* it should **remember this across sessions** and not forget when you close the chat.  

🎮 **Gaming AI NPCs (Non-Playable Characters)**:  
- Imagine playing an RPG where characters **remember past interactions** with you, changing their behavior dynamically!  

---

# 📌 **1️⃣ Implementing Thread-Level Memory in AI Agents**  

### 🔹 **What is Thread-Level Memory?**  
Thread-level memory ensures that an AI **remembers previous messages** in the **same conversation thread.**  

### ✅ **Code Example: Thread-Level Memory in AI Chatbot**
```python
from langgraph.checkpoint.memory import MemorySaver

# ✅ Create an AI agent with thread-level memory
graph = create_react_agent(model, tools, checkpointer=MemorySaver())

# ✅ Define a thread ID for this conversation
config = {"configurable": {"thread_id": "thread-1"}}

# ✅ Function to print chat responses
def print_stream(graph, inputs, config):
    for s in graph.stream(inputs, config, stream_mode="values"):
        message = s["messages"][-1]  # Get last message
        if isinstance(message, tuple):
            print(message)  # Print message if it's a tuple
        else:
            message.pretty_print()  # Otherwise, print it nicely

# ✅ First user message
inputs = {"messages": [("user", "What's the weather in SF?")]}
print_stream(graph, inputs, config)

# ✅ Follow-up message
inputs2 = {"messages": [("user", "Cool, so then should I go biking today?")]}
print_stream(graph, inputs2, config)
```

### 📝 **Explanation: Line by Line**
1. **`from langgraph.checkpoint.memory import MemorySaver`**  
   - Imports `MemorySaver`, which helps the AI **remember messages within the same thread.**  

2. **`graph = create_react_agent(model, tools, checkpointer=MemorySaver())`**  
   - Creates an AI chatbot that can remember messages using `MemorySaver()`.  

3. **`config = {"configurable": {"thread_id": "thread-1"}}`**  
   - Defines a **thread ID** to track conversations within the same chat.  

4. **Function `print_stream()`**  
   - Takes the AI response and **prints messages sequentially** so we can see the chat flow.  

5. **User sends first message: `"What's the weather in SF?"`**  
   - The AI remembers this message.  

6. **User follows up: `"Cool, so then should I go biking today?"`**  
   - AI **remembers** the weather from the first message and **responds intelligently.**  

---

# 📌 **2️⃣ Adding an Interrupt Before Taking Action**  

### 🚀 **Why is This Important?**  
Sometimes, before executing an action, we want the **user to confirm** (e.g., booking a flight or deleting files).  

### ✅ **Code Example: Adding a User Confirmation Step**
```python
graph = create_react_agent(
    model, tools, interrupt_before=["tools"], checkpointer=MemorySaver()
)

config = {"configurable": {"thread_id": "thread-1"}}

inputs = {"messages": [("user", "What's the weather in SF?")]}
print_stream(graph, inputs, config)

# ✅ Save the current state before proceeding
snapshot = graph.get_state(config)
print("Next step: ", snapshot.next)

# ✅ Ask the user to confirm before proceeding
print_stream(graph, None, config)
```

### 📝 **Explanation**
- **`interrupt_before=["tools"]`** → Pauses before using tools (e.g., APIs) to let the user confirm.  
- **`snapshot = graph.get_state(config)`** → Saves the current chat state for future reference.  

---

# 📌 **3️⃣ Implementing Cross-Thread Memory**  

### 🔹 **What is Cross-Thread Memory?**  
- **Thread-Level Memory** works **only inside a single conversation.**  
- **Cross-Thread Memory** allows AI to remember details **across different conversations.**  

### ✅ **Code Example: Cross-Thread Memory**
```python
from langgraph.prebuilt import InjectedStore
from langgraph.store.base import BaseStore

# ✅ Function to save memory across threads
def save_memory(memory: str, *, config: RunnableConfig, store: Annotated[BaseStore, InjectedStore()]) -> str:
    user_id = config.get("configurable", {}).get("user_id")
    namespace = ("memories", user_id)
    store.put(namespace, f"memory_{len(store.search(namespace))}", {"data": memory})
    return f"Saved memory: {memory}"

# ✅ Function to retrieve past memory
def prepare_model_inputs(state: AgentState, config: RunnableConfig, store: BaseStore):
    user_id = config.get("configurable", {}).get("user_id")
    namespace = ("memories", user_id)
    memories = [m.value["data"] for m in store.search(namespace)]
    system_msg = f"User memories: {', '.join(memories)}"
    return [{"role": "system", "content": system_msg}] + state["messages"]

from langgraph.checkpoint.memory import MemorySaver
from langgraph.store.memory import InMemoryStore

store = InMemoryStore()

graph = create_react_agent(model, [save_memory], prompt=prepare_model_inputs, store=store, checkpointer=MemorySaver())

config = {"configurable": {"thread_id": "thread-1", "user_id": "1"}}

inputs = {"messages": [("user", "Hey, I'm Will!")]}

print_stream(graph, inputs, config)

# ✅ AI remembers Will's name in another thread
config2 = {"configurable": {"thread_id": "thread-2", "user_id": "1"}}
inputs2 = {"messages": [("user", "Do you remember me?")]}

print_stream(graph, inputs2, config2)
```

### 📝 **Explanation**
- **Saves user memories in `InMemoryStore()`.**  
- **Retrieves past memories when the same user starts a new thread.**  
- **AI remembers "Will" and his preferences even in a new conversation.**  

---

## 🎯 **Final Thoughts**
✅ **Thread-Level Memory** = Remembers conversation **inside the same chat**  
✅ **Cross-Thread Memory** = Remembers details **across multiple chat sessions**  

### 📌 **Alternative Approaches**
- Use **Databases (SQL, MongoDB)** instead of `InMemoryStore()`.  
- Store memory in **cloud storage** for long-term use.  

Would you like a breakdown of **alternative storage solutions?** 🚀


---


It looks like you want a deep, beginner-friendly explanation of `ToolNode`, how it works, where it can be used in real-world applications, and multiple alternative examples to strengthen your understanding. Below is a detailed breakdown:

---

# 🔧 **Understanding ToolNode in Depth**  

## 🏗 **What is ToolNode?**  
`ToolNode` is a component that runs tool calls made by an AI system. It processes the tools invoked in the last AI-generated message and executes them in parallel if multiple calls are made. It is useful in applications where AI needs to interact with different tools dynamically.

## 🎯 **Where is ToolNode Used in the Real World?**  
1. **Chatbots & AI Assistants** – When an AI assistant needs to fetch data from multiple APIs simultaneously (e.g., weather updates, stock prices, and news).  
2. **Automated Workflows** – When an AI model needs to call external automation tools in a workflow engine.  
3. **Customer Support Bots** – For handling multiple tool-based queries, such as checking order status and retrieving account details.  

---

# 📝 **Breaking Down ToolNode's Functionality**
## 📌 **Key Features**
✅ It executes tools invoked in an AI-generated message.  
✅ Runs multiple tool calls in **parallel** for efficiency.  
✅ Handles tool errors using various customizable strategies.  
✅ Allows direct tool calls or integration in workflows.  

---

## 🛠 **Example 1: Simple ToolNode Implementation**
Let's say we have two tools:  
1. A tool to get the current weather.  
2. A tool to fetch stock prices.

### **🔍 Python Code Example**
```python
from typing import List, Dict
from some_tool_library import BaseTool, ToolMessage

class WeatherTool(BaseTool):
    def invoke(self, args: Dict):
        city = args.get("city", "Unknown")
        return f"The current weather in {city} is 25°C."

class StockPriceTool(BaseTool):
    def invoke(self, args: Dict):
        stock_symbol = args.get("symbol", "AAPL")
        return f"The stock price of {stock_symbol} is $150."

# Creating a ToolNode with both tools
tools = [WeatherTool(), StockPriceTool()]
tools_by_name = {tool.__class__.__name__: tool for tool in tools}

def tool_node(state: dict):
    result = []
    for tool_call in state["messages"][-1].tool_calls:
        tool = tools_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))
    return {"messages": result}
```

---

## 🔍 **Code Explanation**
1️⃣ **We define two tools**: `WeatherTool` and `StockPriceTool`. Each has an `invoke` method that processes input arguments (`args`).  
2️⃣ **Tools return results** based on user requests (e.g., city name or stock symbol).  
3️⃣ **We create a dictionary of tools** (`tools_by_name`) for quick lookup.  
4️⃣ **The `tool_node` function**:
   - Extracts the tool calls from the last AI message.
   - Looks up the corresponding tool by name.
   - Runs the tool’s `invoke` method and stores the result.  
5️⃣ **Outputs a list of `ToolMessage` responses** to return to the AI system.

---

## 🔄 **Example 2: Handling Errors in ToolNode**
What if an error occurs? We can use `handle_tool_errors` to manage it gracefully.

### **🔍 Updated Code**
```python
def tool_node_with_error_handling(state: dict):
    result = []
    for tool_call in state["messages"][-1].tool_calls:
        try:
            tool = tools_by_name[tool_call["name"]]
            observation = tool.invoke(tool_call["args"])
        except Exception as e:
            observation = f"Error processing {tool_call['name']}: {str(e)}"
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))
    return {"messages": result}
```

### **🔍 Explanation**
✔ **Tries to execute the tool call**.  
✔ If an error occurs, it returns an **error message** instead of crashing.  
✔ Ensures the system is **fault-tolerant** and doesn't break due to one failing tool.  

---

## 📡 **Example 3: Using ToolNode in a Conditional Workflow**
Sometimes, tools need to be **dynamically selected** based on conditions.

```python
def example_conditional_edge(state: dict) -> List:
    tool_calls = state["messages"][-1].tool_calls
    selected_tools = [call for call in tool_calls if call["name"] in tools_by_name]
    return [{"type": "Send", "name": "tools", "data": selected_tools}]
```

### **🔍 Explanation**
✅ Filters tool calls based on available tools.  
✅ Ensures only **valid** tool calls are processed.  
✅ Returns a structured **list of tool calls** for execution.  

---

# 🎯 **Key Takeaways**
✔ **`ToolNode` allows AI to interact with external tools dynamically.**  
✔ **Supports parallel execution for multiple tool calls.**  
✔ **Error handling ensures the system remains robust.**  
✔ **Can be used in AI assistants, automation workflows, and customer support bots.**  

Would you like more **real-world examples** or a deeper dive into **specific use cases**? 😊

---

# 🛠️ Understanding `InjectedState` in `langgraph`

## 📌 Introduction  
`InjectedState` is a concept used in **LangGraph**, a framework for managing AI workflows. It allows certain arguments in a tool (function) to be automatically populated with state values, rather than requiring the AI model to provide them.

When an argument is annotated with `InjectedState`, the AI model doesn't generate that argument; instead, the system injects it with the correct value from the state. This is useful when a function (tool) needs context that should not be generated by an AI model but instead retrieved from a pre-existing state.

---

## 🎯 **Real-World Use Case**
Imagine you are building a **chatbot** that remembers past conversations.  
- The chatbot uses a tool (function) that requires past messages as input.  
- Instead of making the AI model generate past messages (which would be incorrect), we use `InjectedState` to **automatically inject** the stored messages into the function.

**Example:**  
- If the chatbot has **fewer than 2 messages**, it replies with `"not enough messages"`.  
- Otherwise, it processes the stored value **foo** (`"bar"`) and returns it concatenated with a number.

---

## 📝 **Code Example with Explanation**
Let's break down the code step by step.

```python
from typing import List
from typing_extensions import Annotated, TypedDict
from langchain_core.messages import BaseMessage, AIMessage
from langchain_core.tools import tool
from langgraph.prebuilt import InjectedState, ToolNode
```

### 📌 **What is happening here?**
- **`TypedDict`**: Defines a dictionary structure with fixed keys.
- **`Annotated`**: Used to indicate which function parameters should be **injected** from the state.
- **`InjectedState`**: Ensures that specific arguments come from the **state** instead of AI-generated inputs.

---

### **1️⃣ Define the State Structure**
```python
class AgentState(TypedDict):
    messages: List[BaseMessage]
    foo: str
```
- **Defines** what kind of information we store in the chatbot's memory:
  - `"messages"` → Stores past chatbot messages.
  - `"foo"` → Stores a specific string value (e.g., `"bar"`).

---

### **2️⃣ Define Functions (Tools) that Use InjectedState**
```python
@tool
def state_tool(x: int, state: Annotated[dict, InjectedState]) -> str:
    '''Do something with state.'''
    if len(state["messages"]) > 2:
        return state["foo"] + str(x)
    else:
        return "not enough messages"
```

#### 📌 **What is happening here?**
- **`state_tool`**: A function (tool) that takes an integer `x` and a **state**.
- **`state: Annotated[dict, InjectedState]`**:
  - The AI model **does not provide** this value.
  - The **system injects** the stored state automatically.
- **Logic**:
  - If there are **more than 2 messages**, return `foo + x` (e.g., `"bar1"`).
  - Otherwise, return `"not enough messages"`.

---

### **3️⃣ Another Example with InjectedState**
```python
@tool
def foo_tool(x: int, foo: Annotated[str, InjectedState("foo")]) -> str:
    '''Do something else with state.'''
    return foo + str(x + 1)
```
#### 📌 **What is happening here?**
- **`foo_tool`**:
  - Takes an integer `x` and a **string `foo` from the state**.
  - Returns `"foo"` concatenated with `x + 1`.

Example:
- If **foo = "bar"** and **x = 1**, then:
  - **Returns `"bar2"`** (since `1 + 1 = 2`).

---

### **4️⃣ Create a ToolNode and Provide State**
```python
node = ToolNode([state_tool, foo_tool])
```
- **`ToolNode`** manages multiple tools.
- **`[state_tool, foo_tool]`**: It can run **both tools**.

---

### **5️⃣ Define Tool Calls**
```python
tool_call1 = {"name": "state_tool", "args": {"x": 1}, "id": "1", "type": "tool_call"}
tool_call2 = {"name": "foo_tool", "args": {"x": 1}, "id": "2", "type": "tool_call"}
```
- **Defines two tool calls** for `state_tool` and `foo_tool` with:
  - `x = 1` in both cases.

---

### **6️⃣ Provide State and Run Tools**
```python
state = {
    "messages": [AIMessage("", tool_calls=[tool_call1, tool_call2])],
    "foo": "bar",
}
node.invoke(state)
```

#### 📌 **What is happening here?**
- **Injecting `state` into tools**:
  - `"messages"` → Contains a past AI message.
  - `"foo"` → `"bar"`.
- **Calling `node.invoke(state)`**:
  - **Automatically fills `InjectedState` parameters**.
  - Runs both `state_tool` and `foo_tool`.

---

### **7️⃣ Expected Output**
```python
[
    ToolMessage(content='not enough messages', name='state_tool', tool_call_id='1'),
    ToolMessage(content='bar2', name='foo_tool', tool_call_id='2')
]
```
- **First tool (`state_tool`)**:
  - Since there are **less than 2 messages**, it returns **"not enough messages"**.
- **Second tool (`foo_tool`)**:
  - `"foo" = "bar"`, and `x+1 = 2`, so it returns **"bar2"**.

---

## 🔄 **Alternative Examples**
To solidify understanding, let's look at **three variations** of `InjectedState`.

---

### **📝 Example 1: Tracking User's Last Input**
```python
@tool
def remember_user_input(user_input: str, last_input: Annotated[str, InjectedState("last_input")]) -> str:
    return f"Your last input was: {last_input}. Your new input is: {user_input}"
```
- **InjectedState `"last_input"`** stores the previous message.
- **Example Output**:  
  - If `"last_input" = "Hello"`, and the new input is `"How are you?"`
  - Returns: `"Your last input was: Hello. Your new input is: How are you?"`

---

### **📝 Example 2: Keeping Track of a Counter**
```python
@tool
def increment_counter(value: int, counter: Annotated[int, InjectedState("counter")]) -> int:
    return counter + value
```
- **Injects `"counter"` from the state**.
- **Example**:
  - If `"counter" = 5` and `value = 2`, returns `7`.

---

### **📝 Example 3: Customizing AI Responses Based on User Role**
```python
@tool
def personalize_response(text: str, role: Annotated[str, InjectedState("user_role")]) -> str:
    if role == "admin":
        return f"Admin says: {text}"
    else:
        return f"User says: {text}"
```
- **Injects `"user_role"` automatically**.
- **Example**:
  - If **role = `"admin"`**, input `"Hello!"` → `"Admin says: Hello!"`.

---

## 🎯 **Why Use InjectedState?**
| Feature        | Benefit |
|---------------|---------|
| ✅ Avoids AI-generated errors | AI doesn't need to generate state-based values |
| ✅ Improves automation | Automatically passes context to functions |
| ✅ Reduces prompt complexity | No need to explicitly pass stored values |

---

## 🏁 **Final Thoughts**
- `InjectedState` ensures that **critical information (like past messages, user roles, or counters)** is **not generated by the AI but provided from the stored state**.
- This **makes tools more reliable** in AI workflows.

---
### 🚀 **Key Takeaways**
✅ **Prevents AI from generating state-based inputs**  
✅ **Automatically injects values from state**  
✅ **Simplifies function calls and AI prompts**  
✅ **Useful for chatbots, memory storage, and context-aware functions**

Would you like a **real-world project example** demonstrating `InjectedState` in action? 😊


---


## 🔥 Understanding `InjectedStore` in LangGraph

`InjectedStore` is a powerful annotation in **LangGraph** that helps inject a store (such as a memory store) into a tool without the model needing to provide it explicitly. This makes the process of handling stored data seamless and efficient.

---

## 📌 What is `InjectedStore`?
- It is an **annotation** for a tool argument that automatically **injects a store** (e.g., `InMemoryStore`).
- It prevents the tool-calling model from **manually generating** the store argument.
- If a **graph is compiled with a store**, it is automatically provided to the tools that require it.

---

## 🚀 Why Use `InjectedStore`?
- **Simplifies tool execution** by removing the need to manually pass the store.
- **Ensures data consistency** across different tool calls.
- **Optimizes automation** in AI workflows where memory/state needs to be maintained.

---

## 🏗️ Real-World Example
Imagine you are building a **smart AI assistant** that keeps track of **previous user interactions** and **remembers key information** during a conversation.

For example:
- A chatbot remembers **user preferences** (e.g., favorite food, past orders).
- A **customer support bot** recalls previous queries to provide better responses.
- A **medical AI** keeps track of patient symptoms across multiple interactions.

With `InjectedStore`, the assistant can **store and retrieve data automatically**, making interactions feel more intelligent and contextual.

---

## 🔥 Code Example: Using `InjectedStore`

### 1️⃣ **Import Required Modules**
```python
from typing import Any
from typing_extensions import Annotated

from langchain_core.messages import AIMessage, ToolMessage
from langchain_core.tools import tool

from langgraph.store.memory import InMemoryStore
from langgraph.prebuilt import InjectedStore, ToolNode
```
📌 **Explanation:**
- We import essential modules for handling AI messages, tools, and memory storage.
- `InMemoryStore` is a temporary storage to hold key-value data.
- `InjectedStore` automatically injects stored data into our tool.

---

### 2️⃣ **Initialize an In-Memory Store**
```python
store = InMemoryStore()  # Create a memory store
store.put(("values",), "foo", {"bar": 2})  # Store a value under the key "foo"
```
📌 **Explanation:**
- `InMemoryStore()` creates an **in-memory key-value store**.
- `store.put(("values",), "foo", {"bar": 2})` stores the dictionary `{"bar": 2}` under the key `"foo"` inside the `"values"` namespace.

---

### 3️⃣ **Define a Tool That Uses the Store**
```python
@tool
def store_tool(x: int, my_store: Annotated[Any, InjectedStore()]) -> str:
    '''Do something with store.'''
    stored_value = my_store.get(("values",), "foo").value["bar"]
    return stored_value + x
```
📌 **Explanation:**
- `@tool` marks this function as a **tool** for LangGraph.
- `my_store: Annotated[Any, InjectedStore()]`:
  - The store is **automatically injected**.
  - The model **doesn’t** need to provide it manually.
- `my_store.get(("values",), "foo").value["bar"]`:
  - Retrieves the value `{ "bar": 2 }` stored under `"foo"`.
  - Extracts `"bar"` which is `2` and returns `bar + x`.

---

### 4️⃣ **Create a ToolNode**
```python
node = ToolNode([store_tool])
```
📌 **Explanation:**
- `ToolNode([store_tool])` registers our tool so it can be executed when invoked.

---

### 5️⃣ **Simulating a Tool Call**
```python
tool_call = {"name": "store_tool", "args": {"x": 1}, "id": "1", "type": "tool_call"}
state = {"messages": [AIMessage("", tool_calls=[tool_call])]}
```
📌 **Explanation:**
- `tool_call` simulates calling `store_tool` with `x = 1`.
- The `state` contains **messages with tool calls**, simulating an AI-generated workflow.

---

### 6️⃣ **Invoke the Node with State and Store**
```python
node.invoke(state, store=store)
```
📌 **Explanation:**
- `node.invoke(state, store=store)` runs the tool **with the injected store**.
- The stored value (`bar = 2`) is retrieved and added to `x (1)`, returning **3**.

---

### 🔥 **Final Output**
```json
{
    "messages": [
        {"content": "3", "name": "store_tool", "tool_call_id": "1"}
    ]
}
```
✅ The tool successfully retrieved the stored value and performed the calculation.

---

## 🏆 Alternative Examples

### 1️⃣ **User Preferences Store**
- Store user preferences (e.g., favorite music, food, language).
- AI assistant remembers preferences for better responses.

```python
store.put(("users",), "unza", {"language": "Urdu", "theme": "dark"})
```
📌 `InjectedStore` allows AI to fetch `"Urdu"` when asked:  
*"What language do I prefer?"* → **"Urdu"**

---

### 2️⃣ **Chatbot Memory Store**
- Store chat history and retrieve previous messages.

```python
store.put(("chat",), "session1", {"history": ["Hello!", "How are you?"]})
```
📌 Chatbot recalls previous messages to maintain **conversation flow**.

---

### 3️⃣ **E-Commerce Cart Store**
- Store user shopping cart items and retrieve them later.

```python
store.put(("cart",), "user123", {"items": ["Laptop", "Phone"]})
```
📌 AI bot can remind users:  
*"You have Laptop and Phone in your cart. Would you like to checkout?"*

---

## 🎯 Summary
🔹 **`InjectedStore`** simplifies memory handling in AI workflows.  
🔹 Automates **data retrieval & storage**, making interactions smarter.  
🔹 Useful for **chatbots, assistants, and AI tools** that require memory.  
🔹 Works seamlessly with **LangGraph’s InMemoryStore**.

💡 **With `InjectedStore`, AI tools can "remember" past interactions, making them more intelligent and user-friendly!** 🚀

---

# 🔧 Understanding `tools_condition` in LangGraph

## 📌 **Introduction to `tools_condition`**
The `tools_condition` function is a critical component in **LangGraph**, which helps decide whether to route execution to a **ToolNode** or end the process. This decision is based on whether the **last message** contains a **tool call**.

### 🔹 **When is `tools_condition` Used?**
- If the **last message** contains a tool call, the function routes execution to the `ToolNode`.
- If there is **no tool call**, it routes to `__end__`, stopping further execution.

### 🔹 **Why is This Useful?**
- Ensures that tool calls are **processed** correctly.
- Prevents unnecessary **computation** if no tool call exists.
- Helps build **custom AI agents** that dynamically decide whether to invoke tools.

---

## 🚀 **Real-World Use Case: AI-Powered Calculator**
Imagine you're building an **AI assistant** that answers questions. If the question requires mathematical calculations, the assistant should call a **calculator tool**; otherwise, it should simply **respond with text**.

For example:
- User: **"What's 329993 divided by 13662?"** → AI routes to the `divide` tool.
- User: **"Tell me a joke."** → AI provides a **text response** without calling a tool.

---

## 🛠️ **Code Explanation with Example**
Let's break down the given code step by step.

### 📜 **Full Code Example**
```python
from langchain_anthropic import ChatAnthropic
from langchain_core.tools import tool
from langgraph.graph import StateGraph
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.graph.message import add_messages
from typing import Annotated
from typing_extensions import TypedDict

# 🛠️ Define a simple tool for division
@tool
def divide(a: float, b: float) -> float:
    """Return a / b."""
    return a / b  # Performs division

# 📡 Define the AI Model (Claude from Anthropic)
llm = ChatAnthropic(model="claude-3-haiku-20240307")

# 🧰 List of available tools
tools = [divide]

# 📂 Define the State structure
class State(TypedDict):
    messages: Annotated[list, add_messages]  # Keeps track of conversation messages

# 📌 Create a StateGraph
graph_builder = StateGraph(State)

# 🔗 Add nodes: one for tools, one for chatbot
graph_builder.add_node("tools", ToolNode(tools))
graph_builder.add_node("chatbot", lambda state: {
    "messages": llm.bind_tools(tools).invoke(state['messages'])
})

# 🔀 Define transitions between nodes
graph_builder.add_edge("tools", "chatbot")  # Tools output goes to chatbot
graph_builder.add_conditional_edges("chatbot", tools_condition)  # Decide next step

# 🚀 Set chatbot as the entry point
graph_builder.set_entry_point("chatbot")

# ✅ Compile the graph
graph = graph_builder.compile()

# 🎯 Invoke with a user query
result = graph.invoke({"messages": {"role": "user", "content": "What's 329993 divided by 13662?"}})
print(result)  # Expected: AI should call `divide` tool and return the result
```

---

## 🔍 **Line-by-Line Breakdown**
### 📌 **Step 1: Import Required Modules**
```python
from langchain_anthropic import ChatAnthropic
from langchain_core.tools import tool
from langgraph.graph import StateGraph
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.graph.message import add_messages
from typing import Annotated
from typing_extensions import TypedDict
```
- **`ChatAnthropic`** → AI language model from Anthropic.
- **`tool`** → Decorator to define a function as a **tool**.
- **`StateGraph`** → Represents a **flowchart** of states and transitions.
- **`ToolNode`** → Node that executes a **tool function**.
- **`tools_condition`** → Determines whether to use **tools** or end execution.
- **`TypedDict`** → Used to define the structure of `State`.

---

### 📌 **Step 2: Define a Simple Tool (Division Function)**
```python
@tool
def divide(a: float, b: float) -> float:
    """Return a / b."""
    return a / b  # Performs division
```
- The `@tool` decorator **registers** the function as a tool.
- Takes two numbers `a` and `b` and returns `a / b`.

📝 **Example Input/Output**
```python
divide(10, 2)  # Output: 5.0
divide(100, 4) # Output: 25.0
```

---

### 📌 **Step 3: Define AI Model (Claude)**
```python
llm = ChatAnthropic(model="claude-3-haiku-20240307")
```
- Initializes **Claude 3 Haiku**, a lightweight AI model.
- This AI will handle text-based queries.

---

### 📌 **Step 4: Register Available Tools**
```python
tools = [divide]
```
- We create a **list of tools** (just `divide` for now).

---

### 📌 **Step 5: Define the State Structure**
```python
class State(TypedDict):
    messages: Annotated[list, add_messages]
```
- This defines a **state dictionary** with:
  - `messages`: A list to store **conversation history**.
- **Why use `TypedDict`?**
  - Ensures **type safety** in our graph.

---

### 📌 **Step 6: Build the StateGraph**
```python
graph_builder = StateGraph(State)
```
- Creates an **empty** `StateGraph` where we will add **nodes** and **connections**.

---

### 📌 **Step 7: Add Nodes for Tools and Chatbot**
```python
graph_builder.add_node("tools", ToolNode(tools))
graph_builder.add_node("chatbot", lambda state: {
    "messages": llm.bind_tools(tools).invoke(state['messages'])
})
```
- **"tools" Node**: Calls the registered tools (`divide` in this case).
- **"chatbot" Node**: Uses AI to respond **if no tool is needed**.

---

### 📌 **Step 8: Define Edges and Conditions**
```python
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_conditional_edges("chatbot", tools_condition)
```
- **Direct tools → chatbot** after execution.
- **Use `tools_condition`** to determine whether to:
  - Call a **tool**.
  - Or just **respond with text**.

---

### 📌 **Step 9: Set Entry Point & Compile**
```python
graph_builder.set_entry_point("chatbot")
graph = graph_builder.compile()
```
- **Entry point**: Execution starts at `"chatbot"`.
- **Compile**: Prepares the graph for execution.

---

### 📌 **Step 10: Invoke with a Query**
```python
result = graph.invoke({"messages": {"role": "user", "content": "What's 329993 divided by 13662?"}})
print(result)
```
- The AI **detects** that this is a **math question**.
- It **routes** execution to the **divide tool**.
- Returns the **calculated result**.

---

## 🎯 **Alternative Examples**
Here are three **alternative** ways to implement similar logic.

### 🔹 **1. Without LangGraph (Manual Handling)**
```python
user_input = "What's 100 / 5?"
if "/" in user_input:
    numbers = [int(n) for n in user_input.split() if n.isdigit()]
    print(numbers[0] / numbers[1])  # Output: 20.0
else:
    print("This is a normal chat response.")
```

---

### 🔹 **2. Using `if-else` Routing**
```python
def chatbot_response(user_message):
    if "divide" in user_message:
        return "Calling divide tool..."
    else:
        return "Responding normally."

print(chatbot_response("Divide 10 by 2"))  # Output: Calling divide tool...
```

---

### 🔹 **3. Using an AI Model (No Tool Calls)**
```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-haiku-20240307")
response = llm.invoke("What's 329993 divided by 13662?")
print(response)
```
- Here, **Claude handles everything** without **calling tools**.

---

## ✅ **Conclusion**
- **`tools_condition`** helps dynamically **route execution**.
- Useful for **AI agents** needing **tool-based actions**.
- Helps **optimize responses** for chatbots and assistants.

Would you like a **deeper** breakdown of a specific part? 🚀

---

It looks like you want a detailed, beginner-friendly explanation of **ValidationNode** in LangGraph with real-world examples, code breakdowns, and alternative implementations. I'll break this down into clear sections with headings, real-world use cases, and line-by-line explanations of the code.

---

# 🔍 **Understanding ValidationNode in LangGraph**

## 📌 **What is ValidationNode?**
A **ValidationNode** in LangGraph is a special type of node that checks if tool calls in an AI-generated response conform to a predefined schema. It **does not execute** the tools but ensures that their input arguments are valid.

✅ **Key Features of ValidationNode:**
- Validates AI-generated tool calls before execution.
- Ensures structured output adheres to predefined schemas.
- Useful for multi-turn conversations where tools need to be invoked correctly.
- Can re-prompt the model to generate valid tool calls if validation fails.

---

## 🏢 **Real-World Example: Where is ValidationNode Used?**
Imagine you're building a **voice assistant** that allows users to book appointments. A user says:

> "Book a dentist appointment for next Tuesday."

The AI model interprets this and calls a **scheduling tool** with the following input:
```json
{
  "date": "2025-02-20",
  "doctor_type": "dentist"
}
```
But what if the AI mistakenly outputs:
```json
{
  "date": "invalid-date",
  "doctor_type": "carpenter"
}
```
Here, **ValidationNode** would:
1. **Catch the invalid date format** and prevent incorrect execution.
2. **Detect an invalid profession ("carpenter" is not a doctor)** and request the AI to correct its response.
3. **Ensure only valid tool calls are executed** to avoid errors in real-world applications.

---

## 📝 **Code Example: Using ValidationNode**
Let’s go through an example step by step.

### 🔹 **Step 1: Import Required Modules**
```python
from typing import Literal, Annotated
from typing_extensions import TypedDict
from langchain_anthropic import ChatAnthropic
from pydantic import BaseModel, validator
from langgraph.graph import END, START, StateGraph
from langgraph.prebuilt import ValidationNode
from langgraph.graph.message import add_messages
```
📌 **Explanation:**
- `ChatAnthropic`: LLM model from Anthropic (Claude).
- `BaseModel, validator`: Used to define and enforce validation rules.
- `ValidationNode`: The key component for validating AI tool calls.

---

### 🔹 **Step 2: Define a Validation Schema**
```python
class SelectNumber(BaseModel):
    a: int

    @validator("a")
    def a_must_be_meaningful(cls, v):
        if v != 37:
            raise ValueError("Only 37 is allowed")
        return v
```
📌 **Explanation:**
- `BaseModel`: Creates a structured schema for tool inputs.
- `a: int`: The tool expects an integer input.
- `@validator("a")`: Ensures `a` can only be **37**; otherwise, it raises an error.

✅ **Why do this?**
- In real-world apps, we use validators to ensure inputs match expected formats, such as valid dates, currency values, or email addresses.

---

### 🔹 **Step 3: Define the AI Model and ValidationNode**
```python
class State(TypedDict):
    messages: Annotated[list, add_messages]

llm = ChatAnthropic(model="claude-3-haiku-20240307").bind_tools([SelectNumber])
```
📌 **Explanation:**
- `State`: Defines a dictionary where messages will be stored.
- `llm.bind_tools([SelectNumber])`: Binds the AI model to the validation schema.

---

### 🔹 **Step 4: Create the Graph and Add Nodes**
```python
builder = StateGraph(State)
builder.add_node("model", llm)
builder.add_node("validation", ValidationNode([SelectNumber]))
builder.add_edge(START, "model")
```
📌 **Explanation:**
- `StateGraph(State)`: Creates a LangGraph workflow.
- `add_node("model", llm)`: Adds the AI model node.
- `add_node("validation", ValidationNode([SelectNumber]))`: Adds the validation node.

---

### 🔹 **Step 5: Define Conditional Routing**
```python
def should_validate(state: list) -> Literal["validation", "__end__"]:
    if state[-1].tool_calls:
        return "validation"
    return END

builder.add_conditional_edges("model", should_validate)
```
📌 **Explanation:**
- If AI generates a **tool call**, the flow moves to the **validation node**.
- Otherwise, it **ends the process**.

---

### 🔹 **Step 6: Handling Errors & Re-Prompting AI**
```python
def should_reprompt(state: list) -> Literal["model", "__end__"]:
    for msg in state[::-1]:  # Check messages in reverse order
        if msg.type == "ai":
            return END
        if msg.additional_kwargs.get("is_error"):
            return "model"
    return END

builder.add_conditional_edges("validation", should_reprompt)
```
📌 **Explanation:**
- If **no errors**, the flow **ends**.
- If **validation fails**, AI is **re-prompted** to generate a correct response.

---

### 🔹 **Step 7: Run the Graph**
```python
graph = builder.compile()
res = graph.invoke(("user", "Select a number, any number"))

for msg in res:
    msg.pretty_print()
```
📌 **Explanation:**
- `graph.invoke()`: Starts the validation workflow.
- `msg.pretty_print()`: Displays the conversation output.

---

## 🏆 **Expected Output**
```plaintext
================================ Human Message =================================
Select a number, any number

================================== Ai Message ==================================
[{'id': 'toolu_01JSjT9Pq8hGmTgmMPc6KnvM', 'input': {'a': 42}, 'name': 'SelectNumber', 'type': 'tool_use'}]
Tool Calls:
SelectNumber (toolu_01JSjT9Pq8hGmTgmMPc6KnvM)
Args:
    a: 42

================================= Tool Message =================================
Name: SelectNumber
ValidationError(model='SelectNumber', errors=[{'loc': ('a',), 'msg': 'Only 37 is allowed', 'type': 'value_error'}])
Respond after fixing all validation errors.

================================== Ai Message ==================================
[{'id': 'toolu_01PkxSVxNxc5wqwCPW1FiSmV', 'input': {'a': 37}, 'name': 'SelectNumber', 'type': 'tool_use'}]
Tool Calls:
SelectNumber (toolu_01PkxSVxNxc5wqwCPW1FiSmV)
Args:
    a: 37

================================= Tool Message =================================
Name: SelectNumber
{"a": 37}
```
✅ **What Happened?**
1. AI initially picked **42** (invalid) → **ValidationNode rejected it**.
2. AI was **re-prompted** and corrected its response to **37**.
3. The validated tool call **passed successfully**.

---

## 🔄 **Alternative Examples**
Here are 3 different ways to use **ValidationNode** in real-world applications.

### 1️⃣ **Validating User Age for Registration**
```python
class UserRegistration(BaseModel):
    age: int

    @validator("age")
    def check_age(cls, v):
        if v < 18:
            raise ValueError("User must be at least 18 years old")
        return v
```
📌 **Prevents users under 18 from signing up.**

---

### 2️⃣ **Ensuring Correct Date Format for Booking System**
```python
from datetime import datetime

class Booking(BaseModel):
    date: str

    @validator("date")
    def check_date_format(cls, v):
        try:
            return datetime.strptime(v, "%Y-%m-%d")
        except ValueError:
            raise ValueError("Date must be in YYYY-MM-DD format")
```
📌 **Ensures correct date format to avoid scheduling errors.**

---

### 3️⃣ **Validating Email Format**
```python
from pydantic import EmailStr

class UserEmail(BaseModel):
    email: EmailStr
```
📌 **Ensures users enter a valid email address.**

---

## 🎯 **Conclusion**
🔹 **ValidationNode** ensures AI-generated tool calls **follow structured formats** before execution.  
🔹 Useful for chatbots, APIs, and any **AI-assisted decision-making** system.  
🔹 Can be used for **age validation, email verification, date checking, and more**.  

🚀 **Next Step:** Try modifying the examples and testing them in your projects! 🚀