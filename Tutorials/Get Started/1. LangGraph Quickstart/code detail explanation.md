# 🔹 **Understanding the Code: Implementing a Tool Node in a Chatbot**  

This code creates a chatbot that can process tool calls using **LangGraph** and **LangChain**. The chatbot dynamically decides whether to call a tool or respond directly based on the latest message.

---

# 🛠 **1. Importing Necessary Libraries**  

```python
import json
from langchain_core.messages import ToolMessage
```

### ✅ **What is happening here?**
- `json`: This module is used to **convert Python objects into JSON** (text format) and vice versa.
- `ToolMessage`: A **message class** from `langchain_core` that is used to **send tool execution results back** to the chatbot.

---
# 🌟 **2. Defining the BasicToolNode Class**  

```python
class BasicToolNode:
    """A node that runs the tools requested in the last AIMessage."""
```
### ✅ **Purpose**
- This class represents a **"Tool Node"** responsible for executing tools **whenever the AI requests them**.

---

## 🏗 **3. Constructor Method (`__init__`)**  
```python
def __init__(self, tools: list) -> None:
    # Store tools in a dictionary with their names as keys for quick lookup
    self.tools_by_name = {tool.name: tool for tool in tools}
```
### ✅ **What is happening here?**
- The constructor receives a **list of tools** and **stores them in a dictionary**.
- **Key** → Tool name  
- **Value** → Tool object  
- This allows **quick access** to a tool using its name.

🔹 **Example**:  
If the tools list contains:  
```python
tools = [Tool(name="weather_tool"), Tool(name="calculator")]
```
It will be stored as:
```python
{
    "weather_tool": ToolObject1,
    "calculator": ToolObject2
}
```
Now, we can access `weather_tool` quickly using `self.tools_by_name["weather_tool"]`.

---

## 🛠 **4. Defining the `__call__` Method**
```python
def __call__(self, inputs: dict):
```
### ✅ **Purpose**
- This function **processes input messages**, checks for tool requests, and executes them.

---
### 🗂 **4.1 Retrieving the Last Message**
```python
if messages := inputs.get("messages", []):
    message = messages[-1]
else:
    raise ValueError("No message found in input")
```
### ✅ **What is happening here?**
- It **extracts the latest message** from the chatbot's message history.
- If no messages are found, it **raises an error**.

🔹 **Example**  
**Given input:**  
```python
inputs = {"messages": ["Hi!", "What’s the weather?", {"tool_calls": [{"name": "weather_tool"}]}]}
```
**Extracted last message:**  
```python
message = {"tool_calls": [{"name": "weather_tool"}]}
```

---
### ⚙ **4.2 Executing the Requested Tool**
```python
outputs = []

for tool_call in message.tool_calls:
    tool_result = self.tools_by_name[tool_call["name"]].invoke(tool_call["args"])
```
### ✅ **What is happening here?**
- It **loops through** all the tool calls in the last message.
- **Finds the correct tool** using its name (`tool_call["name"]`).
- Calls the tool’s **invoke()** function with the provided arguments.

🔹 **Example**  
**Message contains:**  
```python
{"tool_calls": [{"name": "weather_tool", "args": {"location": "Karachi"}}]}
```
- It **retrieves** `weather_tool` and calls:  
```python
weather_tool.invoke({"location": "Karachi"})
```
- This runs the tool and **fetches the weather for Karachi**.

---
### 📩 **4.3 Formatting Tool Responses**
```python
outputs.append(
    ToolMessage(
        content=json.dumps(tool_result),  # Convert tool output to JSON string
        name=tool_call["name"],  # Store the tool's name
        tool_call_id=tool_call["id"],  # Store tool's ID
    )
)
```
### ✅ **What is happening here?**
- Converts the **tool’s result** into a `ToolMessage`, which is **understandable by the chatbot**.
- Stores:
  - `content`: **Tool output in JSON format**
  - `name`: **Tool's name**
  - `tool_call_id`: **Unique ID for tracking**

🔹 **Example**
If `weather_tool` returns:
```python
{"temperature": "30°C", "humidity": "60%"}
```
The chatbot receives:
```python
ToolMessage(content='{"temperature": "30°C", "humidity": "60%"}', name="weather_tool", tool_call_id="123")
```

---
### 🔄 **4.4 Returning Processed Messages**
```python
return {"messages": outputs}
```
### ✅ **What is happening here?**
- It **returns** all the tool responses as **a list of messages**.

---
# 🔹 **5. Adding the Tool Node to the Graph**
```python
tool_node = BasicToolNode(tools=[tool])
graph_builder.add_node("tools", tool_node)
```
### ✅ **What is happening here?**
- **Creates an instance** of `BasicToolNode` and **adds it to the chatbot’s processing graph**.
- This means whenever the chatbot detects a tool call, it will **send the request to this node**.

---
# 🔀 **6. Defining a Router Function (`route_tools`)**
```python
def route_tools(state: State):
```
### ✅ **Purpose**
- This function **routes messages** between chatbot and tools.
- If a **tool is requested**, it goes to `"tools"`; otherwise, it **ends the conversation**.

---
### 📩 **6.1 Extracting Last AI Message**
```python
if isinstance(state, list):
    ai_message = state[-1]
elif messages := state.get("messages", []):
    ai_message = messages[-1]
else:
    raise ValueError(f"No messages found in input state to tool_edge: {state}")
```
### ✅ **What is happening here?**
- If `state` is a **list**, it takes the **last item**.
- If `state` is a **dictionary**, it extracts the **latest message**.
- **If no message exists**, it raises an error.

---
### 🔄 **6.2 Checking for Tool Calls**
```python
if hasattr(ai_message, "tool_calls") and len(ai_message.tool_calls) > 0:
    return "tools"
return END
```
### ✅ **What is happening here?**
- If the chatbot **requested a tool**, return `"tools"`, so the chatbot moves to the tool execution step.
- Otherwise, **return `END`** to stop processing.

---
# 🔁 **7. Adding Conditional Edges to the Graph**
```python
graph_builder.add_conditional_edges(
    "chatbot",
    route_tools,
    {"tools": "tools", END: END},
)
```
### ✅ **What is happening here?**
- **Whenever** the chatbot completes a message:
  - If it needs a tool → **Route to `"tools"`**
  - If no tool is required → **End conversation**

---
# 🔄 **8. Connecting the Nodes**
```python
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")
```
### ✅ **What is happening here?**
- After a tool runs, the chatbot **loops back to itself** (`"tools" → "chatbot"`).
- The chatbot starts execution at the `"chatbot"` node.

---
# 🔧 **9. Compiling the Graph**
```python
graph = graph_builder.compile()
```
### ✅ **What is happening here?**
- **Finalizes the chatbot graph** by connecting all nodes and edges.
- Now, it **knows** when to call tools and when to stop.

---
# 🎯 **Final Summary**
| **Component**      | **Purpose** |
|--------------------|------------|
| `BasicToolNode` | Executes tools when requested. |
| `route_tools()` | Determines whether to call tools or end conversation. |
| `graph_builder.add_conditional_edges()` | Defines chatbot logic for routing. |
| `graph_builder.add_edge()` | Ensures chatbot loops correctly. |
| `graph_builder.compile()` | Finalizes chatbot behavior. |

---
# 🎉 **Conclusion**
- This code **adds tool-calling functionality** to a chatbot.
- The chatbot **detects when a tool is needed** and **executes it** dynamically.
- The **graph-based approach** ensures **efficient control flow**.

🚀 **Now, your chatbot is ready to integrate with tools like weather checkers, calculators, or APIs!**

# 🚀 Building an AI Chatbot That Searches for Updated Information  

## 📝 Introduction  
In this tutorial, we’ll walk through how to build a chatbot using **LangGraph** that can **search for updated information** outside its training data. We'll break down the code **step by step**, explaining every line in a way that beginners can easily understand.  

---

## 🔍 **How Does This Work?**  
1. **User enters a question.**  
2. **Bot processes the question.**  
3. **If needed, it searches for updated information online.**  
4. **Returns the latest results to the user.**  

With this approach, your chatbot can provide **real-time answers** instead of being limited to only pre-trained knowledge!  

---

## 📌 **Step 1: Creating a Loop for User Input**  
First, we create a **loop** so the chatbot continuously listens for user input.  

### **🖥️ Code:**  
```python
while True:
    try:
        user_input = input("User: ")  # Take input from the user
```
### **📖 Explanation:**  
- `while True`: This keeps the chatbot **running indefinitely** until the user decides to exit.  
- `input("User: ")`: This **takes the user's question** as input.  

---

## 🛑 **Step 2: Allowing the User to Exit the Chat**  
We need a way to let users exit the chatbot when they’re done.  

### **🖥️ Code:**  
```python
        if user_input.lower() in ["quit", "exit", "q"]:
            print("Goodbye!")
            break
```
### **📖 Explanation:**  
- `.lower()`: Converts the input to **lowercase** (so "QUIT" and "quit" are treated the same).  
- `in ["quit", "exit", "q"]`: If the user types any of these commands, we:  
  1. Print `"Goodbye!"`  
  2. `break` out of the loop, stopping the chatbot.  

---

## 🔄 **Step 3: Processing the User's Query**  
Now, let's process the input by sending it to our **search function**.  

### **🖥️ Code:**  
```python
        stream_graph_updates(user_input)
```
### **📖 Explanation:**  
- `stream_graph_updates(user_input)`: Calls a **function** that processes the user's query and fetches updated information.  

---

## ⚠️ **Step 4: Handling Errors (Fallback Mechanism)**  
What if something goes wrong? We need a **fallback mechanism** in case `input()` doesn't work (e.g., in certain environments).  

### **🖥️ Code:**  
```python
    except:
        # fallback if input() is not available
        user_input = "What do you know about LangGraph?"
        print("User: " + user_input)
        stream_graph_updates(user_input)
        break
```
### **📖 Explanation:**  
- `except:`: This **catches any errors** and ensures the chatbot doesn't crash.  
- `user_input = "What do you know about LangGraph?"`: If an error occurs, we **automatically send a predefined query** instead.  
- `print("User: " + user_input)`: This **prints the query** so the user knows what’s being asked.  
- `break`: Stops the chatbot **after handling the error**.  

---

## 🔎 **Step 5: Bot Searches for Information**  
The chatbot calls an **AI tool** that searches for the latest details on the topic.  

### **Example Response:**  
```json
[
  {"text": "To provide you with accurate and up-to-date information about LangGraph, I'll need to search for the latest details. Let me do that for you."},
  {"id": "toolu_01Q588CszHaSvvP2MxRq9zRD", "input": {"query": "LangGraph AI tool information"}, "name": "tavily_search_results_json", "type": "tool_use"}
]
```
### **📖 Explanation:**  
- The assistant first **notifies the user** that it needs to search.  
- Then, it **uses an AI search tool** (`tavily_search_results_json`) to find relevant data.  

---

## 📢 **Step 6: Displaying Search Results**  
Once the search is complete, the assistant presents the information.  

### **Example Output:**  
```json
[
  {
    "url": "https://www.langchain.com/langgraph",
    "content": "LangGraph sets the foundation for how we can build and scale AI workloads..."
  },
  {
    "url": "https://github.com/langchain-ai/langgraph",
    "content": "LangGraph is a library for building stateful, multi-actor applications with LLMs..."
  }
]
```
### **📖 Explanation:**  
- The bot **fetches relevant results** and provides links to sources.  
- This ensures users **get the latest data** instead of outdated training info.  

---

## 📊 **Step 7: Understanding LangGraph (Bot’s Summary)**  
After retrieving results, the bot **summarizes** the key points:  

### **📌 Key Takeaways About LangGraph**  
✅ **Purpose:**  
- LangGraph is a **library** for building **multi-agent AI applications**.  

✅ **Developer:**  
- Created by **LangChain**, an AI tools company.  

✅ **Key Features:**  
- **Cycles:** Supports **looping workflows** for better automation.  
- **Controllability:** Gives developers **more control** over responses.  
- **Persistence:** Maintains **state and memory** across interactions.  

✅ **Use Cases:**  
- Conversational AI  
- Task automation  
- AI-powered workflows  

✅ **Integration:**  
- Works with **LangSmith**, a tool for managing AI models.  

✅ **Availability:**  
- **Open-source** and available on **GitHub**.  

✅ **Comparison with Other Tools:**  
- Unlike traditional LLM tools, **LangGraph handles cycles and memory** better.  

---

## 🎉 **Final Thoughts: You've Built an AI Chatbot with Search Capabilities!**  
✅ **Your chatbot can now answer questions beyond its training data!**  
✅ **It fetches real-time information using AI search tools.**  
✅ **Handles errors and fallback gracefully.**  

With this setup, you've built a **smart conversational AI** that can continuously update itself with new knowledge! 🚀🔥  

---

## 🛠️ **Next Steps: Enhancing the Bot**  
Want to make it even better? Here are some **bonus improvements:**  
✅ **Use APIs like Google Search or OpenAI’s knowledge retrieval.**  
✅ **Cache results to improve response speed.**  
✅ **Improve summarization for more human-like responses.**  

---

💡 **What’s your next AI project? Let me know in the comments! 🚀**

# 🧠 Adding Memory to a Chatbot with LangGraph

A chatbot that doesn't remember past interactions struggles to maintain a natural, multi-turn conversation. In this section, we'll **add memory to our chatbot** using **LangGraph's checkpointing system**, allowing it to retain context across multiple user inputs.

---

## 🏗️ Why Does a Chatbot Need Memory?

By default, chatbots **only process one user query at a time** and forget past conversations. This makes interactions feel disconnected. 

### 🚀 **Solution: Checkpointing with LangGraph**
LangGraph provides **persistent checkpointing**, allowing a chatbot to:
✅ Remember previous messages  
✅ Maintain context in multi-turn conversations  
✅ Save and resume complex workflows  
✅ Recover from errors  

---

## 📝 Step 1: Setting Up Memory with `MemorySaver`

We need to **store past messages** so the chatbot can recall previous interactions. We'll use **LangGraph's in-memory checkpointer** for this tutorial.

### 🔹 **Code Example: Creating a Checkpointer**
```python
from langgraph.checkpoint.memory import MemorySaver

# Create an in-memory checkpointer to store conversation history
memory = MemorySaver()
```
### 📌 **Explanation:**
- `MemorySaver()` creates an **in-memory storage** for chatbot history.
- This allows the chatbot to remember past messages **within a single session**.
- In production, you should use a **database-backed checkpointer** like:
  - `SqliteSaver` (for small applications)
  - `PostgresSaver` (for scalable applications)

---

## 📝 Step 2: Defining the Chatbot's Processing Graph

LangGraph organizes chatbot interactions as a **graph of connected nodes**.  
We'll define the **state** of our chatbot and the logic it follows.

### 🔹 **Code Example: Defining the State**
```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages

# Define a chatbot state to store messages
class State(TypedDict):
    messages: Annotated[list, add_messages]
```

### 📌 **Explanation:**
- `State` is a **dictionary-like object** that stores chatbot data.
- `messages` is a **list of previous interactions**, ensuring the chatbot has context.
- `add_messages` automatically **appends new messages** to the conversation history.

---

## 📝 Step 3: Creating the Chatbot Logic

Now, we **define the chatbot's thinking process** using LangGraph's tools.

### 🔹 **Code Example: Setting Up the AI Model**
```python
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults

# Load the AI model (Claude AI from Anthropic)
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")

# Add a search tool for better responses
tool = TavilySearchResults(max_results=2)
tools = [tool]

# Bind the AI model with tools
llm_with_tools = llm.bind_tools(tools)
```

### 📌 **Explanation:**
- `ChatAnthropic(model="claude-3-5-sonnet-20240620")` initializes **Claude 3.5 Sonnet**, a powerful AI model.
- `TavilySearchResults()` lets the chatbot **fetch real-time search results**.
- `bind_tools()` connects the AI model to external tools **so it can answer with up-to-date information**.

---

## 📝 Step 4: Defining the Chatbot's Workflow

Now, we build a **graph of steps** that the chatbot follows.

### 🔹 **Code Example: Creating the Chatbot Node**
```python
from langgraph.graph import StateGraph, START, END

# Create a chatbot function that processes user input
def chatbot(state: State):
    return {"messages": [llm_with_tools.invoke(state["messages"])]}

# Build the chatbot's workflow as a state graph
graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)
```

### 📌 **Explanation:**
- `StateGraph(State)` initializes a **workflow graph** that tracks chatbot interactions.
- `add_node("chatbot", chatbot)` creates a **chatbot node** that receives user input and generates responses.

---

## 📝 Step 5: Adding Tool Execution

Next, we integrate **tool execution** into the chatbot.

### 🔹 **Code Example: Adding a Tool Node**
```python
from langgraph.prebuilt import ToolNode, tools_condition

# Add a node for executing tools
tool_node = ToolNode(tools=[tool])
graph_builder.add_node("tools", tool_node)

# Define the chatbot's decision-making flow
graph_builder.add_conditional_edges(
    "chatbot",
    tools_condition,
)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")
```

### 📌 **Explanation:**
- `ToolNode(tools=[tool])` automatically **executes API calls** when needed.
- `tools_condition` **decides whether to call a tool** (e.g., when a search is required).
- `add_edge("tools", "chatbot")` ensures **tools return control to the chatbot** after execution.

---

## 📝 Step 6: Enabling Memory in the Graph

We **compile the chatbot with memory**, so it remembers past interactions.

### 🔹 **Code Example: Compiling the Graph with Checkpointing**
```python
# Compile the chatbot with memory for conversation persistence
graph = graph_builder.compile(checkpointer=memory)
```

### 📌 **Explanation:**
- `compile(checkpointer=memory)` enables **persistent memory**, ensuring the chatbot remembers past conversations.

---

## 📝 Step 7: Running the Chatbot

Now, we interact with the chatbot, providing a **thread ID** to maintain memory.

### 🔹 **Code Example: Choosing a Thread ID**
```python
# Use a unique thread ID to persist conversation history
config = {"configurable": {"thread_id": "1"}}
```
### 📌 **Explanation:**
- `thread_id="1"` ensures that **all messages in this session are linked together**.
- If we **use the same thread ID later**, the chatbot will remember previous messages.

---

## 📝 Step 8: Chatting with the Bot

Finally, we **send a message** and observe the chatbot’s response.

### 🔹 **Code Example: Sending a Message**
```python
user_input = "Hi there! My name is Will."

# Send input and retrieve chatbot responses
events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    config,
    stream_mode="values",
)

# Print chatbot responses
for event in events:
    event["messages"][-1].pretty_print()
```

### 📌 **Explanation:**
- `graph.stream(...)` **sends user input** to the chatbot.
- `stream_mode="values"` ensures **real-time responses**.
- `pretty_print()` formats the chatbot’s reply for easy reading.

---

## 🎉 **Final Output**
```
================================ Human Message ================================
Hi there! My name is Will.

================================== AI Message ================================
Hello Will! It's nice to meet you. How can I assist you today? 
```

The chatbot now **remembers the user’s name** and can maintain context in a conversation!

---

## 🚀 **What Did We Achieve?**
✅ **Added memory** to retain past conversations  
✅ **Integrated real-time tools** for enhanced responses  
✅ **Enabled state persistence** using LangGraph  

This is just the beginning! Checkpointing allows for **advanced AI workflows**, including:
🔹 Error recovery  
🔹 Human-in-the-loop interactions  
🔹 Multi-agent collaboration  

Would you like to add **more advanced memory techniques** or a **database-backed memory system** next? 🚀


Here's a detailed explanation of the content, broken down into structured sections with clear headings, explanations, and code breakdowns.

---

# 🧠 Understanding Conversation State with LangGraph

In this guide, we will explore how LangGraph handles conversation memory and maintains state using checkpointing. We will analyze a chatbot that remembers or forgets user inputs based on configuration settings.

---

## 🔍 **What is LangGraph?**
LangGraph is a system that helps manage conversation flows while maintaining memory using **checkpoints**. A **checkpoint** saves the conversation history, allowing the AI to "remember" past interactions.

---

## ⚙️ **Config and Graph Execution**
LangGraph allows us to pass a **configuration object** when running a conversation graph. This determines whether the chatbot retains memory or starts fresh.

```python
user_input = "Remember my name?"

# The config is the **second positional argument** to stream() or invoke()!
events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    config,  # Configuration object
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

### 📌 **Code Breakdown**
1. **`user_input = "Remember my name?"`**  
   - The user is asking the chatbot to recall their name.

2. **`graph.stream(...)`**  
   - Calls the LangGraph stream function, which processes messages.
   - First argument: `{"messages": [{"role": "user", "content": user_input}]}`  
     - This tells the AI what the user said.
   - Second argument: `config`  
     - This determines whether memory is enabled.
   - `stream_mode="values"`  
     - The AI outputs results as a stream of events.

3. **Looping through events**
   - `event["messages"][-1].pretty_print()`  
     - Displays the last AI response in a readable format.

### 💡 **Expected Output**
```
================================  Human Message  ================================
Remember my name?
==================================  AI Message  ================================
Of course, I remember your name, Will.
```

Since we provided a **config object**, the chatbot remembers previous interactions.

---

## 🔄 **Changing the Configuration (Forgetting Memory)**
If we modify the **config**, the chatbot forgets past interactions.

```python
events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    {"configurable": {"thread_id": "2"}},  # New thread ID (new memory session)
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

### 📌 **Code Breakdown**
1. **New `config` object**  
   - `{"configurable": {"thread_id": "2"}}`  
   - Instead of using the original `thread_id`, we use `"2"`, simulating a **new conversation session**.

2. **Effect of Change**  
   - The chatbot no longer remembers previous messages.

### 💡 **Expected Output**
```
================================  Human Message  ================================
Remember my name?
==================================  AI Message  ================================
I apologize, but I don't have any previous context or memory of your name.
```

Even though we asked the same question, the chatbot **forgot the user's name** because we started a new session.

---

## 🛠 **Inspecting Conversation State**
We can inspect the chatbot’s memory at any point using `get_state(config)`.

```python
snapshot = graph.get_state(config)
snapshot
```

### 📌 **Code Breakdown**
- **`graph.get_state(config)`**  
  - Fetches the stored conversation history.
- **Contents of `snapshot`**  
  - It includes:
    - The **messages exchanged** between the user and AI.
    - The **configuration settings** (e.g., `thread_id`).
    - Metadata (e.g., token usage, timestamps).

### 💡 **Example Output (If Memory Exists)**
```json
{
  "values": {
    "messages": [
      {"role": "user", "content": "Hi there! My name is Will."},
      {"role": "ai", "content": "Hello Will! It's nice to meet you."},
      {"role": "user", "content": "Remember my name?"},
      {"role": "ai", "content": "Of course, I remember your name, Will."}
    ]
  }
}
```

This output shows that **memory is being stored**.

### 💡 **Example Output (If Memory is Reset)**
```json
{
  "values": {
    "messages": [
      {"role": "user", "content": "Remember my name?"},
      {"role": "ai", "content": "I apologize, but I don't have any previous context."}
    ]
  }
}
```

Since `thread_id` was changed, the chatbot started a fresh conversation.

---

## 🎯 **Key Takeaways**
✅ **LangGraph uses checkpointing** to remember past messages.  
✅ **Config settings (like `thread_id`) control memory.**  
✅ **`graph.get_state(config)` helps debug the stored conversation.**  
✅ **Changing the `thread_id` resets memory.**  

---

## 🎉 **Conclusion**
By understanding **configuration, state inspection, and memory retention**, you can build **conversational AI that remembers user context across sessions**. 🎯🚀

# 🤖 Human-in-the-loop Chatbot with LangGraph

In this section, we introduce **human oversight** into our chatbot. This allows the bot to pause for human guidance or approval before proceeding. This approach is useful when the AI might be uncertain or when you want to ensure that critical tasks are verified by a person.

Below, we walk through the code step-by-step, explaining every line in detail.

---

## 🛠️ **1. Importing Libraries and Tools**

```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.tools import tool
from typing_extensions import TypedDict

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition

from langgraph.types import Command, interrupt
```

### Explanation:
- **`from typing import Annotated` & `from typing_extensions import TypedDict`**  
  - **Purpose:** To define structured types for our chatbot’s state.
- **`ChatAnthropic`**  
  - **Purpose:** Imports the Anthropic language model (e.g., Claude) for generating responses.
- **`TavilySearchResults`**  
  - **Purpose:** Imports a tool for web search to get updated information.
- **`tool` decorator from `langchain_core.tools`**  
  - **Purpose:** Marks a Python function as a callable tool that the chatbot can use.
- **`MemorySaver`**  
  - **Purpose:** Provides an in-memory checkpointing system to save conversation state.
- **`StateGraph, START, END`**  
  - **Purpose:** Constructs the workflow graph, where `START` and `END` indicate the entry and exit points.
- **`add_messages`**  
  - **Purpose:** A helper to manage appending messages to our conversation state.
- **`ToolNode, tools_condition`**  
  - **Purpose:** Prebuilt components to manage tool calls within the chatbot.
- **`Command, interrupt`**  
  - **Purpose:**  
    - `interrupt` is used to pause the chatbot and ask for human input.
    - `Command` is used to resume the process with human feedback (though not explicitly shown in this snippet).

---

## 📋 **2. Defining the Chatbot State**

```python
class State(TypedDict):
    messages: Annotated[list, add_messages]
```

### Explanation:
- **`State`**  
  - **Purpose:** Defines our conversation state as a dictionary.
- **`messages: Annotated[list, add_messages]`**  
  - **Purpose:**  
    - `messages` is a list that stores all messages exchanged.
    - `add_messages` ensures new messages are appended rather than replacing the list.

---

## 🔨 **3. Building the Chatbot Graph**

```python
graph_builder = StateGraph(State)
```

### Explanation:
- **`StateGraph(State)`**  
  - **Purpose:** Initializes a graph that will manage our conversation flow using the defined `State`.

---

## 👥 **4. Adding a Human Assistance Tool**

```python
@tool
def human_assistance(query: str) -> str:
    """Request assistance from a human."""
    human_response = interrupt({"query": query})
    return human_response["data"]
```

### Explanation:
- **`@tool` decorator**  
  - **Purpose:** Registers `human_assistance` as a callable tool within our chatbot.
- **`def human_assistance(query: str) -> str:`**  
  - **Purpose:**  
    - This function takes a `query` (a string) that represents what the AI wants to ask a human.
- **`human_response = interrupt({"query": query})`**  
  - **Purpose:**  
    - `interrupt` pauses the chatbot execution and sends the query to a human operator.
    - It waits for human input, which is returned as `human_response`.
- **`return human_response["data"]`**  
  - **Purpose:** Extracts and returns the actual data from the human's response.

---

## 🔧 **5. Setting Up Tools and AI Model**

```python
tool = TavilySearchResults(max_results=2)
tools = [tool, human_assistance]
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")
llm_with_tools = llm.bind_tools(tools)
```

### Explanation:
- **`tool = TavilySearchResults(max_results=2)`**  
  - **Purpose:**  
    - Creates a search tool that fetches up to 2 results from the web.
- **`tools = [tool, human_assistance]`**  
  - **Purpose:**  
    - Combines the search tool and our new human assistance tool into a list of available tools.
- **`llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")`**  
  - **Purpose:**  
    - Instantiates the Anthropic AI model (Claude) for generating chatbot responses.
- **`llm_with_tools = llm.bind_tools(tools)`**  
  - **Purpose:**  
    - Binds the list of tools to the AI model so that the model can call them when necessary.

---

## 💬 **6. Defining the Chatbot Node**

```python
def chatbot(state: State):
    message = llm_with_tools.invoke(state["messages"])
    # Because we will be interrupting during tool execution,
    # we disable parallel tool calling to avoid repeating any
    # tool invocations when we resume.
    assert len(message.tool_calls) <= 1
    return {"messages": [message]}
```

### Explanation:
- **`def chatbot(state: State):`**  
  - **Purpose:**  
    - Defines a function that processes the conversation state.
- **`message = llm_with_tools.invoke(state["messages"])`**  
  - **Purpose:**  
    - Sends the entire conversation history to the AI model.
    - The model then returns a new message, which may include tool calls.
- **`assert len(message.tool_calls) <= 1`**  
  - **Purpose:**  
    - Ensures that only one tool call is made at a time.
    - This is important when using `interrupt` so that parallel tool executions are prevented, avoiding duplicated or conflicting operations.
- **`return {"messages": [message]}`**  
  - **Purpose:**  
    - Returns the new message as part of the updated state, ensuring the conversation history is maintained.

---

## 🔀 **7. Integrating Nodes into the Graph**

```python
graph_builder.add_node("chatbot", chatbot)

tool_node = ToolNode(tools=tools)
graph_builder.add_node("tools", tool_node)
```

### Explanation:
- **`graph_builder.add_node("chatbot", chatbot)`**  
  - **Purpose:**  
    - Adds the `chatbot` function as a node to the graph, named `"chatbot"`.
- **`tool_node = ToolNode(tools=tools)`**  
  - **Purpose:**  
    - Instantiates a prebuilt `ToolNode` which automatically handles tool calls.
- **`graph_builder.add_node("tools", tool_node)`**  
  - **Purpose:**  
    - Adds the `tool_node` to the graph with the name `"tools"`.

---

## 🔄 **8. Defining Control Flow with Conditional Edges**

```python
graph_builder.add_conditional_edges(
    "chatbot",
    tools_condition,
)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")
```

### Explanation:
- **`graph_builder.add_conditional_edges("chatbot", tools_condition)`**  
  - **Purpose:**  
    - Sets up a conditional check after the `chatbot` node.
    - `tools_condition` determines if a tool (like human assistance) needs to be invoked.
- **`graph_builder.add_edge("tools", "chatbot")`**  
  - **Purpose:**  
    - After a tool has been executed, the control returns to the `chatbot` node to continue the conversation.
- **`graph_builder.add_edge(START, "chatbot")`**  
  - **Purpose:**  
    - Establishes that the conversation starts at the `chatbot` node.

---

## 🎯 **Summary**

- **Human-in-the-loop:**  
  - The code integrates a **human assistance tool** using `interrupt`, enabling the chatbot to pause and get human guidance when needed.
- **Tools and AI Model:**  
  - The chatbot is equipped with both a **web search tool** and a **human assistance tool**, managed by the AI model.
- **Graph Workflow:**  
  - The conversation flow is managed by a **state graph**, with nodes for the chatbot and tool execution.
- **Conditional Routing:**  
  - **Conditional edges** ensure that the chatbot calls the appropriate tool when required and then resumes the conversation.

This setup enables a robust, human-in-the-loop chatbot that can leverage external input to handle uncertain situations, ensuring greater reliability and user satisfaction.

Would you like to see further enhancements or additional examples of human-in-the-loop integrations? Let me know!

---

# o3 response:

# 🧠 Understanding Human-in-the-Loop with LangGraph

In this section, we introduce the concept of **human-in-the-loop** (HITL) in AI agents. This is a technique that ensures human oversight for certain tasks, allowing an AI system to request human intervention or guidance when necessary. It's important for making sure that AI systems can work more reliably by handling complex or ambiguous situations where human judgment is required.

Let's break down each part in detail, from the code setup to how it interacts with the system, and how it can be visualized.

## 🛠️ Compiling the Graph with a Checkpointer

First, let’s look at how we set up the graph with a **checkpointer**.

```python
memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)
```

### Explanation:
- **MemorySaver**: This class helps save the state of the process, ensuring that the system can "pause" and "resume" operations at any time.
- **graph_builder.compile(checkpointer=memory)**: This line compiles the graph (which is essentially our workflow or process flow) and links it with the `memory` so that it can save and restore the state.

This setup allows us to **pause** the execution of the graph and **resume** later, based on human input or any other conditions.

## 🖼️ Visualizing the Graph

Once the graph is built and compiled, we can visualize it to understand the flow better.

```python
from IPython.display import Image, display

try:
    display(Image(graph.get_graph().draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass
```

### Explanation:
- **graph.get_graph().draw_mermaid_png()**: This function draws the graph as a **Mermaid** diagram (a type of flowchart).
- **Image**: Displays the visualized diagram.
- **try/except block**: Since this requires additional dependencies, the exception handling ensures that if the dependencies aren’t installed, the program won’t crash.

The graph visualization helps to check the workflow and see the layout after adding a new tool (in this case, human-in-the-loop functionality).

## 🧑‍💻 Using the `human_assistance` Tool

Now, let's move on to using the **human_assistance** tool, which interacts with a human when needed.

### The Code for `human_assistance`:

```python
@tool
def human_assistance(query: str) -> str:
    """Request assistance from a human."""
    human_response = interrupt({"query": query})
    return human_response["data"]
```

### Explanation:
- **@tool**: This decorator marks `human_assistance` as a tool that can be used by the LangGraph system.
- **interrupt({"query": query})**: The `interrupt` function pauses the execution of the graph and waits for human input. The `query` is the information we want to get assistance on.
- **human_response["data"]**: After human input is received, the function returns the data that the human provides.

In simple terms, whenever the system encounters an uncertainty or needs clarification, it calls this tool to ask a human for help.

## 💬 Prompting the Chatbot

Next, let's see how we use this tool in practice with an example prompt from the user.

```python
user_input = "I need some expert guidance for building an AI agent. Could you request assistance for me?"
config = {"configurable": {"thread_id": "1"}}

events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    config,
    stream_mode="values",
)
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

### Explanation:
- **user_input**: This is the message the user sends to the chatbot, asking for expert guidance on building an AI agent.
- **graph.stream()**: This method sends the input to the graph for processing. It starts the flow of events and waits for the necessary responses.
- **event["messages"][-1].pretty_print()**: Once an event is processed, this line prints out the last message in a human-readable format.

When this input is processed, the system identifies that it needs human assistance (using the `human_assistance` tool).

## ✋ Pausing the Graph Execution

The system then pauses the execution as it waits for human input:

```python
snapshot = graph.get_state(config)
snapshot.next
```

### Explanation:
- **graph.get_state(config)**: This function retrieves the current state of the graph. This is where the execution paused.
- **snapshot.next**: This is used to inspect the next step, which will be resumed later after receiving the human input.

This allows the chatbot to **pause** execution and wait for the human response before continuing.

## 🧑‍🏫 Resuming the Execution After Human Input

After receiving the human input, we can resume the execution by passing a `Command` object.

```python
human_response = (
    "We, the experts are here to help! We'd recommend you check out LangGraph to build your agent."
    " It's much more reliable and extensible than simple autonomous agents."
)

human_command = Command(resume={"data": human_response})

events = graph.stream(human_command, config, stream_mode="values")
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

### Explanation:
- **human_response**: This is the expert’s response, given after receiving input from the human. The system will use this response to continue processing.
- **Command(resume={"data": human_response})**: The `Command` object is used to resume execution. It contains the data (human response) that will allow the system to continue its process.
- **graph.stream(human_command, config, stream_mode="values")**: This restarts the graph's execution with the new input from the human.

This is how the graph can **pause and resume** based on real-time human input, enabling flexibility in how the AI agent works.

## 🎉 The Result

When all the steps are completed, the system will return the expert’s advice:

```
We, the experts are here to help! We'd recommend you check out LangGraph to build your agent.
It's much more reliable and extensible than simple autonomous agents.
```

This response contains the expert advice that will help guide the user on building an AI agent. The flow completes successfully because the AI waited for the human's confirmation before proceeding.

## Conclusion: Adding Human-in-the-Loop for Enhanced Reliability

By adding **human-in-the-loop** functionality, we can ensure that AI agents handle complex tasks more reliably. The integration of tools like `interrupt` allows the system to pause and resume, providing an efficient way to handle human intervention without losing progress.

---
# 🚀 Adding Human Oversight with Checkpointing and Interrupts

In this section, we enhance our chatbot by adding **human-in-the-loop** functionality. This means the bot can pause its automated execution to request expert help or human confirmation before continuing. We also persist the conversation state using a checkpointer so that we can resume where we left off.

Below, we explain the code step-by-step.

---

## 🛠️ 1. Compiling the Graph with a Checkpointer

We start by setting up our **checkpointing** mechanism to save the chatbot’s state between turns.

### **Code Example:**

```python
memory = MemorySaver()

graph = graph_builder.compile(checkpointer=memory)
```

### **Line-by-Line Explanation:**

- **`memory = MemorySaver()`**  
  - **Purpose:**  
    - Creates an in-memory checkpointer to store the conversation state (the history of messages).  
    - This is useful for our tutorial, but in production, you might use a database-backed saver (like Postgres or SQLite) for persistence.

- **`graph = graph_builder.compile(checkpointer=memory)`**  
  - **Purpose:**  
    - Compiles our LangGraph workflow (graph) using the checkpointer (`memory`).  
    - This ensures that after each node execution, the current state is saved.
  - **Why It's Important:**  
    - If the conversation pauses (for human intervention) or if execution is interrupted, the state is saved and can later be resumed seamlessly.

---

## 🖼️ 2. Visualizing the Graph

We can visualize our conversation flow (graph) to see its layout and verify that our human assistance tool has been added.

### **Code Example:**

```python
from IPython.display import Image, display

try:
    display(Image(graph.get_graph().draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass
```

### **Line-by-Line Explanation:**

- **`from IPython.display import Image, display`**  
  - **Purpose:**  
    - Imports functions to display images within a Jupyter Notebook.

- **`try:` ... `except Exception:`**  
  - **Purpose:**  
    - Attempts to generate a visual diagram (using Mermaid) of the graph.  
    - If dependencies are missing, it safely skips the visualization.
  
- **`graph.get_graph().draw_mermaid_png()`**  
  - **Purpose:**  
    - Generates a PNG image of the graph using Mermaid syntax.
  
- **`display(Image(...))`**  
  - **Purpose:**  
    - Displays the generated image so you can visually inspect the chatbot workflow.

---

## 💬 3. Prompting the Chatbot to Engage the Human Assistance Tool

Next, we simulate a scenario where the chatbot is asked for expert guidance. This prompt will trigger the **human_assistance** tool.

### **Code Example:**

```python
user_input = "I need some expert guidance for building an AI agent. Could you request assistance for me?"
config = {"configurable": {"thread_id": "1"}}

events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    config,
    stream_mode="values",
)
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

### **Line-by-Line Explanation:**

- **`user_input = "I need some expert guidance for building an AI agent. Could you request assistance for me?"`**  
  - **Purpose:**  
    - Sets up the user's query, requesting expert assistance.

- **`config = {"configurable": {"thread_id": "1"}}`**  
  - **Purpose:**  
    - Defines the configuration for this conversation session.  
    - The `thread_id` ensures that all messages in this session are part of the same conversation memory.

- **`graph.stream(...)`**  
  - **Purpose:**  
    - Sends the user input into the chatbot graph.  
    - **Parameters:**
    - First argument: The conversation state with the new message.
    - Second argument: The `config` object (passed as the second positional argument, not nested in the message).
    - `stream_mode="values"`: Outputs responses as stream events.

- **`for event in events:` ...**  
  - **Purpose:**  
    - Iterates through each event (or step) returned by the graph execution.  
    - **`event["messages"][-1].pretty_print()`** prints the most recent message from the chatbot in a readable format.

---

## 🔍 4. Inspecting the Graph State

After the chatbot generates a tool call (using the human assistance tool), execution is paused. We can inspect the graph’s state to see where it stopped.

### **Code Example:**

```python
snapshot = graph.get_state(config)
snapshot.next
```

### **Line-by-Line Explanation:**

- **`snapshot = graph.get_state(config)`**  
  - **Purpose:**  
    - Retrieves the current saved state of the conversation from the checkpointer using the same configuration.
  
- **`snapshot.next`**  
  - **Purpose:**  
    - Indicates the next node in the graph that is waiting to execute.
  - **Example Output:**  
    - `('tools',)`  
      - This shows that the graph paused at the `tools` node because the human assistance tool was called.

---

## ⏸️ 5. How the Human Assistance Tool Works

Let’s review the human assistance tool that uses the `interrupt` function to pause execution and request human input.

### **Code Example:**

```python
@tool
def human_assistance(query: str) -> str:
    """Request assistance from a human."""
    human_response = interrupt({"query": query})
    return human_response["data"]
```

### **Line-by-Line Explanation:**

- **`@tool` decorator**  
  - **Purpose:**  
    - Registers the function as a tool that the chatbot can call.
  
- **`def human_assistance(query: str) -> str:`**  
  - **Purpose:**  
    - Defines a function that takes a string `query` and returns a string.  
    - This query is what the chatbot will ask a human for guidance.
  
- **`human_response = interrupt({"query": query})`**  
  - **Purpose:**  
    - Calls the `interrupt` function, pausing the execution and sending the query to a human operator.
    - The function waits for human input and then returns the response.
  
- **`return human_response["data"]`**  
  - **Purpose:**  
    - Extracts the actual response data from the human's reply and returns it.

---

## 🔄 6. Resuming Execution with a Command Object

After human intervention, we resume the chatbot’s execution by providing a `Command` object containing the human response.

### **Code Example:**

```python
human_response = (
    "We, the experts are here to help! We'd recommend you check out LangGraph to build your agent."
    " It's much more reliable and extensible than simple autonomous agents."
)

human_command = Command(resume={"data": human_response})

events = graph.stream(human_command, config, stream_mode="values")
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

### **Line-by-Line Explanation:**

- **`human_response = (...)`**  
  - **Purpose:**  
    - Defines a string that simulates the expert advice provided by a human.
  
- **`human_command = Command(resume={"data": human_response})`**  
  - **Purpose:**  
    - Wraps the human response in a `Command` object.
    - The key `"resume"` signals that this command should resume the paused execution, and the contained `"data"` is what the human provided.
  
- **`events = graph.stream(human_command, config, stream_mode="values")`**  
  - **Purpose:**  
    - Resumes the execution of the chatbot graph by passing the `human_command` and the same configuration.
    - The graph uses the human response to continue processing.
  
- **`for event in events:` ...**  
  - **Purpose:**  
    - Iterates through the resulting events and prints the latest chatbot message.

---

## 🎉 7. Final Outcome

When execution resumes, the chatbot processes the human intervention and then produces a final response that incorporates the expert advice. The conversation continues, with the state fully preserved, thanks to checkpointing.

### **What Happens Under the Hood:**

- **Graph State Persistence:**  
  - The conversation state, including the human intervention, is saved using the checkpointer.
  
- **Human-in-the-Loop:**  
  - The chatbot temporarily halts execution (using `interrupt`) to get human input.
  - The execution resumes with the provided command, allowing the chatbot to incorporate human feedback.

- **Seamless Resumption:**  
  - The checkpointing system allows the conversation to resume from where it left off, providing a smooth user experience.

---

## 🚀 Conclusion

By compiling the graph with a checkpointer and integrating the **human_assistance** tool with `interrupt`, we've enabled a robust human-in-the-loop mechanism. This approach ensures:
- **Enhanced reliability:** Critical decisions can be verified by a human.
- **State persistence:** The conversation state is maintained across interruptions.
- **Flexibility:** You can pause and resume execution at any time.

This setup is ideal for scenarios where human oversight is essential, such as in complex AI applications or when handling sensitive tasks.

Feel free to explore further and customize the human assistance process to meet your application's needs!

# 🤖 Human-in-the-loop Workflows & Customizing State

Human-in-the-loop workflows allow us to combine the power of automation with the insight and judgment of humans. This means that before certain automated actions are executed, a human can review, verify, or modify the information. This leads to more reliable systems, especially when the stakes are high or when decisions are too complex for an AI to handle alone.

In this guide, we'll explain how you can customize your chatbot's state to include additional fields (like a name and birthday) and integrate a human-in-the-loop workflow that lets a human review data before it’s saved. We'll break down the code and provide real-world examples along the way.

---

## 🌟 What Are Human-in-the-loop Workflows?

Human-in-the-loop workflows are processes where:
- **Automation performs most tasks.**
- **Humans intervene for validation or correction** when needed.

### Real-World Example:
Imagine an online banking system that uses AI to flag suspicious transactions. Before freezing an account, a human analyst reviews the details to ensure that the transaction is indeed fraudulent. This reduces false positives and ensures customers are not inconvenienced by automatic decisions.

---

## 🛠️ Customizing the Chatbot State

### Why Customize State?
Our chatbot initially stored only a list of messages. However, for more advanced behavior (like verifying details), we can add extra fields. In this example, we add:
- **`name`**: To store an entity's name.
- **`birthday`**: To store the entity’s birthday.

### Code Example: Defining the Custom State

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import add_messages

# Define a custom state that includes messages, name, and birthday.
class State(TypedDict):
    messages: Annotated[list, add_messages]  # Holds conversation history
    name: str                                 # Additional field for name
    birthday: str                             # Additional field for birthday
```

### Explanation:
- **`TypedDict`**: Creates a dictionary type with specific fields.
- **`messages`**: Annotated with `add_messages` so that new messages are appended.
- **`name` & `birthday`**: New fields for storing extra information, accessible to any graph node.

---

## 🛠️ Integrating Human-in-the-loop: The `human_assistance` Tool

We now add a tool that allows a human to verify the data (like name and birthday) before updating the state.

### Code Example: Defining the `human_assistance` Tool

```python
from langchain_core.messages import ToolMessage
from langchain_core.tools import InjectedToolCallId, tool
from langgraph.types import Command, interrupt
from typing import Annotated

@tool
def human_assistance(
    name: str, 
    birthday: str, 
    tool_call_id: Annotated[str, InjectedToolCallId]
) -> str:
    """Request assistance from a human."""
    # Pause execution and ask the human if the provided name and birthday are correct.
    human_response = interrupt({
        "question": "Is this correct?",
        "name": name,
        "birthday": birthday,
    })
    
    # If the human confirms the data is correct, use it as-is.
    if human_response.get("correct", "").lower().startswith("y"):
        verified_name = name
        verified_birthday = birthday
        response = "Correct"
    else:
        # Otherwise, allow the human to provide corrections.
        verified_name = human_response.get("name", name)
        verified_birthday = human_response.get("birthday", birthday)
        response = f"Made a correction: {human_response}"
    
    # Prepare a state update with a ToolMessage to update the conversation state.
    state_update = {
        "name": verified_name,
        "birthday": verified_birthday,
        "messages": [ToolMessage(response, tool_call_id=tool_call_id)],
    }
    
    # Return a Command object to update the state.
    return Command(update=state_update)
```

### Explanation:
- **`@tool` decorator**: Registers `human_assistance` as a callable tool.
- **Parameters**:
  - `name` and `birthday`: Data to be verified.
  - `tool_call_id`: A special identifier (annotated with `InjectedToolCallId`) ensuring that this ID isn’t exposed to the language model.
- **`interrupt` Function**:
  - Pauses the execution and sends the data to a human with a prompt ("Is this correct?").
  - Waits for human input.
- **Conditional Logic**:
  - If the human confirms (the response starts with "y"), the data is accepted.
  - Otherwise, the human can provide corrections.
- **State Update**:
  - A new state update is created with the verified `name` and `birthday`, along with a `ToolMessage` containing the response.
- **Return Command**:
  - The function returns a `Command` object with the state update, which the system uses to update the conversation state.

---

## 🔄 Integrating the Custom State and Tools into the Graph

The rest of our graph is similar to previous setups, but now we use our custom state and include the human assistance tool.

### Code Example: Full Graph Integration

```python
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode, tools_condition

# Define tools: a web search tool and our human_assistance tool.
tool = TavilySearchResults(max_results=2)
tools = [tool, human_assistance]

# Initialize the AI model.
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")
llm_with_tools = llm.bind_tools(tools)

# Chatbot node that processes conversation.
def chatbot(state: State):
    message = llm_with_tools.invoke(state["messages"])
    # Ensure only one tool call is made to prevent duplication.
    assert len(message.tool_calls) <= 1
    return {"messages": [message]}

# Build the state graph.
graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)

# Add the tool execution node.
tool_node = ToolNode(tools=tools)
graph_builder.add_node("tools", tool_node)

# Set up conditional routing: call tools if needed.
graph_builder.add_conditional_edges("chatbot", tools_condition)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")

# Set up the in-memory checkpointer.
memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)
```

### Explanation:
- **Tools Setup**:
  - We include both the **TavilySearchResults** tool for web searches and the **human_assistance** tool.
- **AI Model Binding**:
  - `llm_with_tools` binds our tools to the AI model so that it can call them as needed.
- **Chatbot Function**:
  - Invokes the AI model with the current state (which now includes `name` and `birthday` fields).
  - Uses an assertion to ensure a single tool call at a time.
- **Graph Building**:
  - Constructs the state graph with nodes for `chatbot` and `tools`.
  - Sets up conditional edges to determine when to invoke tool calls.
- **Checkpointing**:
  - The graph is compiled with a `MemorySaver` to persist the state across interactions.

---

## 🚀 Real-World Application: Research and Verification Chatbot

Imagine a research assistant chatbot used by a news agency. When the chatbot gathers data about a public figure, such as their name and birthday, it can:
- **Automatically fetch the information** from the web.
- **Pause to request human verification** before publishing the information.
- **Update its state** with verified details, ensuring accurate reporting.

This workflow improves the reliability of automated reporting by incorporating human oversight.

---

## 🌟 Summary

- **Human-in-the-loop workflows** add human oversight to AI, increasing reliability and trust.
- **Customizing state** allows us to store additional data (e.g., name, birthday) for more complex interactions.
- **The `human_assistance` tool** uses `interrupt` to pause execution and request human verification.
- **Real-world use case:** A news assistant verifying details about public figures before publishing information.

By combining automated data collection with human validation, systems can achieve a higher standard of accuracy and user satisfaction.

Would you like to explore more advanced customizations or additional human-in-the-loop examples? Let me know!

---

# Understanding Human-in-the-loop Workflow with LangGraph
### 🌟 **What is Human-in-the-loop Workflow?**
Human-in-the-loop (HITL) is a type of system design that involves humans as an active participant in the loop to review, validate, or correct information processed by an automated system. The idea is to combine the power of machine learning with human expertise, allowing for a feedback system that improves accuracy and decision-making in complex tasks. In simpler terms, it’s like having a helper (the machine) that works autonomously, but when it encounters something tricky, it asks a human for guidance.

**Real-World Example:**
Imagine a medical AI system that reads X-ray images. While the AI can identify most issues, it might not be 100% accurate in certain edge cases. Hence, it prompts a doctor (the human) to review and confirm its diagnosis.

### 🛠️ **Scenario: Searching and Reviewing LangGraph's Birthday**
In this example, we are simulating a chatbot that searches for information about LangGraph’s release date, uses an automated search tool, and then asks for human validation using the **human_assistance** tool. Let’s break down the key concepts and explore the flow of the code:

---

### 🔍 **Step 1: User Input and Stream Processing**
```python
user_input = (
    "Can you look up when LangGraph was released? "
    "When you have the answer, use the human_assistance tool for review."
)
```
- **Purpose**: This string is a query from the user asking for the release date of **LangGraph**. 
- The chatbot will first search for the information and then ask for a human's confirmation.

```python
config = {"configurable": {"thread_id": "1"}}
```
- **Purpose**: This is configuration data. It’s a setup for tracking the request or conversation in a specific thread. Think of it as a reference ID to keep track of interactions.

```python
events = graph.stream(
    {"messages": [{"role": "user", "content": user_input}]},
    config,
    stream_mode="values",
)
```
- **Purpose**: Here, we send the user input through a stream to the graph. The chatbot will process this input and interact with various tools (like searching for information).
- The stream mode `"values"` means that we are interested in the raw output without additional metadata.

### 💻 **Step 2: AI Message Processing**
The chatbot searches for information using the **TavilySearchResults** tool and attempts to find the release date of **LangGraph**.
```python
{'text': "Certainly! I'll start by searching for information about LangGraph's release date using the Tavily search function. Then, I'll use the human_assistance tool for review.", 'type': 'text'}
```
- **Purpose**: The AI informs the user that it is searching for the release date of LangGraph.

### 🛠️ **Step 3: Tool Calls**
Next, the chatbot makes a tool call to search for the release date of LangGraph.
```python
{'id': 'toolu_01JoXQPgTVJXiuma8xMVwqAi', 'input': {'query': 'LangGraph release date'}, 'name': 'tavily_search_results_json', 'type': 'tool_use'}
```
- **Purpose**: The chatbot sends a search query to **TavilySearchResults** asking for LangGraph's release date.

### 🤖 **Step 4: Human Assistance Tool**
After gathering some information, the AI realizes that the search results do not give an exact release date. So, it asks for human assistance:
```python
{'id': 'toolu_01JDQAV7nPqMkHHhNs3j3XoN', 'input': {'name': 'Assistant', 'birthday': '2023-01-01'}, 'name': 'human_assistance', 'type': 'tool_use'}
```
- **Purpose**: The AI is requesting human help to verify or correct the release date of LangGraph, by passing it to the **human_assistance** tool. The `name` and `birthday` are placeholders for potential corrections.

### ✅ **Step 5: Human Correction**
When a human responds, the chatbot receives the corrected information.
```python
human_command = Command(
    resume={
        "name": "LangGraph",
        "birthday": "Jan 17, 2024",
    },
)
```
- **Purpose**: The **human_assistance** tool provided the correct release date. Now, the chatbot is instructed to resume with the updated information. The **Command** object is used to resume processing the flow with the corrected information.

### 🎯 **Step 6: Final Output**
The chatbot now delivers the accurate release date, thanks to the human review process:
```python
LangGraph was initially released on January 17, 2024. This information comes from the human assistance correction, which is more accurate than the search results I initially found.
```
- **Purpose**: The chatbot now presents the final corrected information to the user after receiving human assistance.

### 🔄 **Step 7: Snapshot of the State**
Finally, a snapshot of the current state is captured:
```python
snapshot = graph.get_state(config)
{k: v for k, v in snapshot.values.items() if k in ("name", "birthday")}
```
- **Purpose**: This stores the current state of the conversation, which includes the corrected name and birthday (release date). This makes the information easily accessible to other parts of the system.

---

### 💡 **Conclusion:**
In this flow, we used **Human-in-the-loop** to ensure the accuracy of information that the chatbot retrieved from an automated search. The human was involved when the AI couldn't confidently determine the correct data. The process highlights the importance of combining AI and human intelligence, especially when dealing with ambiguity or complex information.

---

### 🎉 **Real-World Applications of Human-in-the-loop:**
1. **Customer Service**: Automated chatbots can handle routine inquiries but escalate to human agents when the query is complex.
2. **Healthcare**: AI can assist doctors in diagnosing diseases, but doctors can validate and confirm the diagnosis before any decisions are made.
3. **Autonomous Vehicles**: While self-driving cars can navigate independently, human drivers are still needed to intervene in complicated or unforeseen situations.

---

### 💻 **Code Summary**
- **Step 1**: The chatbot initiates a search request for LangGraph’s release date.
- **Step 2**: AI uses automated tools to search for the date.
- **Step 3**: If the search results are not sufficient, the chatbot asks for human assistance to verify the details.
- **Step 4**: The corrected information is stored in the state, ensuring all future interactions are accurate.

This demonstrates how **Human-in-the-loop** systems can enhance AI’s accuracy and reliability, especially in uncertain or complex scenarios.

# **Manually Updating State in LangGraph** 🛠️

In LangGraph, **state management** is a crucial part of building a flexible, interactive application. One of the powerful features that LangGraph provides is the ability to manually update the application state whenever needed. This control over the state can be very useful for a variety of scenarios, especially when you need to store and modify dynamic data during execution.

### **What is Application State?** 💡

The **state** of an application refers to the data that the application keeps track of during its lifecycle. This data can include things like user inputs, system configurations, or any other variable that can change over time. Managing the state allows you to store information that can be used later, either for processing, displaying, or triggering specific actions.

For example, consider a **chat application** where you are keeping track of the current user’s name, the message history, and the time of the last message. This information constitutes the **state** of the application.

### **How LangGraph Handles State Updates** 🔄

LangGraph allows you to update the application state manually at any point. This means you can change or modify key-value pairs in the application's state, which will later be reflected throughout the workflow.

### **Why Manual State Updates?** 🤔

There might be situations where you need to **explicitly** update certain values during the execution of a task, without waiting for natural triggers (like a user input or an automatic event). In such cases, manual state updates allow you to control the flow of data actively. It gives you more **flexibility** in the workflow, especially when working with **complex tasks** or **human-in-the-loop interactions**.

For example, if a tool or service calls for specific data that is not automatically fetched, you can manually update the state to ensure the process continues smoothly.

### **Key Functions:**
- `graph.update_state`: This function allows you to manually override or update a key in the application state.
- `graph.get_state`: After updating, you can retrieve the current state of the application to verify if the changes have been applied successfully.

---

## **Let's Break It Down with Code** 🖥️

### **Code Example for Manual State Update**

```python
# Updating the state manually with a new name for the application
graph.update_state(config, {"name": "LangGraph (library)"})

# Now, we retrieve the current state and check the values
snapshot = graph.get_state(config)

# We are specifically interested in the "name" and "birthday" values
{k: v for k, v in snapshot.values.items() if k in ("name", "birthday")}
```

### **Step-by-Step Explanation** 📝

1. **Updating the State** 🛠️
    ```python
    graph.update_state(config, {"name": "LangGraph (library)"})
    ```
    - **Purpose**: This line manually updates the `name` field in the state to "LangGraph (library)".
    - **How it works**: The `update_state()` function takes two arguments:
      - `config`: This is the configuration that defines how the state is updated (it contains essential information like thread ID).
      - `{"name": "LangGraph (library)"}`: This dictionary represents the data being added to the state. We're specifically setting the value of the `name` key to `"LangGraph (library)"`.

2. **Fetching the Current State** 🔍
    ```python
    snapshot = graph.get_state(config)
    ```
    - **Purpose**: After updating the state, we call `get_state()` to fetch the current state. This will allow us to verify if our changes have been applied successfully.
    - **How it works**: This function returns the complete state of the application, which includes all the keys and their corresponding values.

3. **Filtering for Specific Keys** 🧹
    ```python
    {k: v for k, v in snapshot.values.items() if k in ("name", "birthday")}
    ```
    - **Purpose**: We filter the state to show only the keys we're interested in: `name` and `birthday`.
    - **How it works**: This line iterates over the items in `snapshot.values` (which is a dictionary containing all the state data) and selects only the keys that match `"name"` or `"birthday"`.
    - The result is a dictionary that only includes those specific keys and their corresponding values, which in this case will look like:
      ```python
      {'name': 'LangGraph (library)', 'birthday': 'Jan 17, 2024'}
      ```

---

## **Real-World Example: Customer Profile Management** 💼

Let's consider a **real-world scenario** where this concept of manual state updates can be used effectively.

### **Scenario: Updating Customer Profile in an E-Commerce App**

Imagine you're building an e-commerce platform. You have a customer profile page that displays the customer’s **name**, **email**, **address**, and **purchase history**. 

- During the checkout process, you might need to update the customer’s **shipping address** manually if the customer enters a new one.
- The profile page should reflect this change in real-time to ensure that the correct address is used for the shipment.

Here, the application state is updated manually to reflect the new shipping address. This ensures that even if the customer modifies their address in the middle of the checkout process, the system will accurately reflect the updated address on the profile page.

---

## **State Management in Human-in-the-Loop Workflows** 🤖

In more complex workflows involving human inputs, LangGraph allows you to update the state to reflect human decisions or corrections. For example, if a machine learning model processes data but is uncertain about certain values, a human might intervene to correct the data. You can then manually update the state to store that corrected information.

**Example Workflow**:
- A machine learning model classifies documents but is unsure about a few. The model flags these for human review.
- A human checks the documents and provides the correct classifications.
- You then manually update the state with the correct values using `graph.update_state()`, allowing the application to proceed with the accurate data.

---

## **Conclusion: The Power of Manual State Updates** 🎯

Manual state updates in LangGraph give you precise control over how data is managed and flow-controlled throughout your application. By using `graph.update_state()`, you can change key values dynamically and ensure that your application remains responsive and up-to-date with the most relevant data.

This approach is especially valuable when:
- You need to store intermediate results during execution.
- You want to control workflows involving human intervention.
- You need flexibility in managing application data over time.

By understanding how to use state management in LangGraph, you can build more powerful and interactive applications that are easy to maintain and scale.

---

```python
from typing import Annotated

from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import ToolMessage
from langchain_core.tools import InjectedToolCallId, tool
from typing_extensions import TypedDict

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.types import Command, interrupt



class State(TypedDict):
    messages: Annotated[list, add_messages]
    name: str
    birthday: str


@tool
def human_assistance(
    name: str, birthday: str, tool_call_id: Annotated[str, InjectedToolCallId]
) -> str:
    """Request assistance from a human."""
    human_response = interrupt(
        {
            "question": "Is this correct?",
            "name": name,
            "birthday": birthday,
        },
    )
    if human_response.get("correct", "").lower().startswith("y"):
        verified_name = name
        verified_birthday = birthday
        response = "Correct"
    else:
        verified_name = human_response.get("name", name)
        verified_birthday = human_response.get("birthday", birthday)
        response = f"Made a correction: {human_response}"

    state_update = {
        "name": verified_name,
        "birthday": verified_birthday,
        "messages": [ToolMessage(response, tool_call_id=tool_call_id)],
    }
    return Command(update=state_update)


tool = TavilySearchResults(max_results=2)
tools = [tool, human_assistance]
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")
llm_with_tools = llm.bind_tools(tools)


def chatbot(state: State):
    message = llm_with_tools.invoke(state["messages"])
    assert(len(message.tool_calls) <= 1)
    return {"messages": [message]}


graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)

tool_node = ToolNode(tools=tools)
graph_builder.add_node("tools", tool_node)

graph_builder.add_conditional_edges(
    "chatbot",
    tools_condition,
)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")

memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)

```

Let's break down this code to understand each part, the role of each component, and how it all works together to implement state management and interaction in the **LangGraph** framework. I'll explain step-by-step and provide code examples along with real-world use cases.

---

## **Code Overview** 📝

This script sets up a chatbot application that incorporates **human-in-the-loop assistance**. It uses a combination of LangChain tools, LangGraph's state management, and memory-saving features. The **goal** of the code is to manage application state, request human assistance when needed, and integrate multiple tools for a cohesive workflow.

### **Step 1: Importing Necessary Libraries** 📦

```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import ToolMessage
from langchain_core.tools import InjectedToolCallId, tool
from typing_extensions import TypedDict
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.types import Command, interrupt
```

- **Imports**:
  - **LangChain tools**: `ChatAnthropic`, `TavilySearchResults`, etc., are used to interface with external services and APIs like chat models and search results.
  - **LangGraph components**: These handle the state, memory, and graph construction, essential for managing the chatbot's flow.

---

## **Step 2: Define the State** 📊

```python
class State(TypedDict):
    messages: Annotated[list, add_messages]
    name: str
    birthday: str
```

- **State class**:
  - We define the **state structure** using `TypedDict`. This helps ensure type safety and clearly defines what data will be managed in the application.
  - `messages`: A list that stores the conversation history.
  - `name`: Represents the name of the user (could be dynamically set during conversation).
  - `birthday`: Stores the user's birthday (again, can be set during the interaction).

---

## **Step 3: Human Assistance Tool** 👥

```python
@tool
def human_assistance(
    name: str, birthday: str, tool_call_id: Annotated[str, InjectedToolCallId]
) -> str:
    """Request assistance from a human."""
    human_response = interrupt(
        {
            "question": "Is this correct?",
            "name": name,
            "birthday": birthday,
        },
    )
    if human_response.get("correct", "").lower().startswith("y"):
        verified_name = name
        verified_birthday = birthday
        response = "Correct"
    else:
        verified_name = human_response.get("name", name)
        verified_birthday = human_response.get("birthday", birthday)
        response = f"Made a correction: {human_response}"

    state_update = {
        "name": verified_name,
        "birthday": verified_birthday,
        "messages": [ToolMessage(response, tool_call_id=tool_call_id)],
    }
    return Command(update=state_update)
```

- **Human Assistance Tool**:
  - This is a **custom tool** (decorated with `@tool`) designed to interact with a human user when the system is unsure about the information (in this case, `name` and `birthday`).
  - **interrupt**: Triggers an interrupt for human assistance with a question, asking if the data is correct.
  - If the human confirms the data, it is saved as is. If not, the human can update the values.
  - After verification, it updates the **state** (i.e., `name`, `birthday`) and appends a message to the conversation history.
  - **state_update**: This dictionary contains the updated values to reflect in the system's state.

### **Real-World Use Case**:
In a **customer support chatbot**, if the bot is unsure about user information (like a name or address), it can ask the user for confirmation or correction. For example, in an e-commerce website, a bot may ask: "Is your shipping address correct?" If the customer answers "no", the bot can request the correct address and update the system's state.

---

## **Step 4: Define the Chatbot** 🤖

```python
def chatbot(state: State):
    message = llm_with_tools.invoke(state["messages"])
    assert(len(message.tool_calls) <= 1)
    return {"messages": [message]}
```

- **Chatbot function**:
  - **`llm_with_tools.invoke`**: This function call sends the current `messages` to the **language model** (e.g., `ChatAnthropic`), which processes the conversation and generates the next response.
  - **State Management**: The chatbot generates responses based on the state’s **messages** (conversation history).
  - The `assert` ensures that the chatbot generates no more than one tool call at a time.

### **Real-World Example**:
Imagine a virtual assistant in a helpdesk chat application. The assistant processes the ongoing conversation, keeping track of past messages and generating responses accordingly. If the assistant needs more data, it can invoke external tools or human assistance (like the `human_assistance` function above).

---

## **Step 5: Constructing the Graph** 🧠

```python
graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)

tool_node = ToolNode(tools=tools)
graph_builder.add_node("tools", tool_node)

graph_builder.add_conditional_edges(
    "chatbot",
    tools_condition,
)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")

memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)
```

- **StateGraph**: 
  - The graph is the backbone of the application, representing the flow of tasks and interactions.
  - **Nodes** are the functions (like `chatbot`, `tools`), and **edges** represent how they are connected or invoked.
  - The `add_conditional_edges` function adds logic for when to switch between tasks (e.g., chatbot conversation → tools for human assistance).
  - **MemorySaver**: This helps save and recall previous states, preserving the conversation history.

### **Real-World Use Case**:
In a **multi-step process**, such as filling out a user profile with validation steps (e.g., confirming name, address), the process flow can be modeled as a state graph. The graph decides the order of actions (chatbot asks questions, human verifies data, etc.).

---

## **Final Thoughts** 🧩

### **Summary**:
- **State management** is vital for keeping track of the ongoing conversation and user input.
- LangGraph provides a highly flexible **state graph** that lets you manually update and manage data.
- The **human assistance tool** allows for human-in-the-loop interaction to verify or update critical data.

### **Use Case Recap**:
This framework can be applied in a variety of **chatbots**, **customer support systems**, and **user profiling applications**. It ensures a smooth, interactive experience where the application state is always up to date, with manual interventions when necessary.

---

By using LangGraph in this way, you can create intelligent systems capable of handling dynamic interactions, ensuring that the system works seamlessly and flexibly, even with real-time human input.

# Part 6: Time Travel ⏳

In this section, we will dive into a fascinating concept—**Time Travel**—as implemented in LangGraph. This feature allows a chatbot (or any state-based system) to "rewind" to a previous point in its execution. You can then resume from that checkpoint to explore alternative outcomes or correct mistakes.

---

### **What is Time Travel in LangGraph?**
Time travel functionality allows us to **revisit past states** of a system and **branch off** from there. This is incredibly useful when you want to go back and change a decision or explore a different outcome from a specific point in time. It's commonly used in systems where users need to fix mistakes or experiment with different strategies without starting from scratch.

For example, in autonomous software engineering, a chatbot or an assistant could help engineers debug code. If a mistake is made, instead of redoing the entire process, the system can "rewind" to the point just before the mistake and try a different approach.

### **Real-World Example:**
Consider an autonomous assistant that helps a software developer write code. If the assistant suggests an error-prone solution, the developer might want to go back to the previous state of the conversation, analyze the error, and try a new path without redoing all steps. LangGraph's time travel feature helps with such workflows by storing each state and allowing the system to revert to earlier points.

---

### **Key Concepts of Time Travel**

1. **State Checkpoints:** 
   A **state checkpoint** is essentially a snapshot of the system's state at a specific point in time. In LangGraph, every interaction with the system creates a checkpoint that you can refer back to.

2. **Fetching History:** 
   LangGraph provides a method called `get_state_history`, which allows you to retrieve a history of states. You can go back to a specific point in the past and continue from there.

3. **Rewinding:** 
   Rewinding the system refers to fetching a previous state and resuming the execution from that state. This enables users to **explore different outcomes** or **correct errors**.

---

### **Code Example:**

Let's walk through a chatbot workflow and demonstrate how time travel works in LangGraph. Here's an example code for setting up a simple chatbot:

```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import BaseMessage
from typing_extensions import TypedDict
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition


# Define the state structure with messages
class State(TypedDict):
    messages: Annotated[list, add_messages]


# Initialize the graph builder
graph_builder = StateGraph(State)

# Define the tool and bind it to the chatbot
tool = TavilySearchResults(max_results=2)
tools = [tool]
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")
llm_with_tools = llm.bind_tools(tools)


# Define the chatbot's response generation logic
def chatbot(state: State):
    return {"messages": [llm_with_tools.invoke(state["messages"])]}

# Add the chatbot node to the graph
graph_builder.add_node("chatbot", chatbot)

# Add the tool node and condition for tool invocation
tool_node = ToolNode(tools=[tool])
graph_builder.add_node("tools", tool_node)

graph_builder.add_conditional_edges("chatbot", tools_condition)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")

# Initialize memory for checkpointing
memory = MemorySaver()
graph = graph_builder.compile(checkpointer=memory)
```

### **Explanation of Each Line of Code:**

#### 1. **Imports:**
```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import BaseMessage
from typing_extensions import TypedDict
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
```
- We're importing necessary modules from **LangGraph** and other libraries like **LangChain** to enable the chatbot, tools, and memory features.

#### 2. **State Definition:**
```python
class State(TypedDict):
    messages: Annotated[list, add_messages]
```
- The `State` class defines the data structure used to represent the chatbot's state. It contains a `messages` field that will hold the conversation history.

#### 3. **Graph Setup:**
```python
graph_builder = StateGraph(State)
```
- Here, we create an instance of **StateGraph**, which is the framework that manages the flow of state transitions and checkpointing.

#### 4. **Tool Initialization:**
```python
tool = TavilySearchResults(max_results=2)
tools = [tool]
```
- We define a search tool (TavilySearchResults) to be used within the chatbot to fetch search results. It will return a maximum of 2 results.

#### 5. **Bot Logic:**
```python
def chatbot(state: State):
    return {"messages": [llm_with_tools.invoke(state["messages"])]}
```
- This function defines the chatbot's behavior. It takes the state (messages) and uses **ChatAnthropic** to generate responses.

#### 6. **Adding Nodes to the Graph:**
```python
graph_builder.add_node("chatbot", chatbot)
tool_node = ToolNode(tools=[tool])
graph_builder.add_node("tools", tool_node)
```
- We add the chatbot and tools as nodes in the state graph. Each node represents a part of the workflow, and transitions will occur between them.

#### 7. **Conditional Edges:**
```python
graph_builder.add_conditional_edges("chatbot", tools_condition)
```
- This line specifies the conditions under which the chatbot node should transition to the tools node.

#### 8. **Memory Checkpointing:**
```python
memory = MemorySaver()
```
- We initialize **MemorySaver**, which will handle the checkpointing and store the states.

---

### **Time Travel in Action:**

Now that we’ve set up the chatbot workflow, let's simulate how "time travel" works:

```python
# Simulating a chat session
config = {"configurable": {"thread_id": "1"}}
events = graph.stream(
    {
        "messages": [
            {"role": "user", "content": "I'm learning LangGraph. Could you do some research on it for me?"}
        ],
    },
    config,
    stream_mode="values",
)

# Print the messages at each event
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

This section simulates a user interaction. The **events** are generated in a chat session, and at each step, the system prints out the generated message. These events are saved in the **memory**.

---

### **Conclusion:**

Time travel in LangGraph enables you to revisit previous states and make changes based on past decisions. This is a powerful tool for building interactive systems that require flexibility, such as chatbots, autonomous assistants, and AI-driven workflows.

In real-world applications, this could be used in scenarios like debugging, interactive storytelling, and even in healthcare to trace patient information over time and explore different outcomes.

By understanding how to utilize time travel in LangGraph, you can build more dynamic and flexible systems that cater to complex decision-making processes.

# Understanding LangGraph and Autonomous Agents

LangGraph is a framework that facilitates the development of autonomous agents. These agents can process tasks step-by-step using various tools and workflows. Let's break down the provided code and understand its purpose, logic, and how it can be applied in the real world.

## What is LangGraph?

LangGraph is a tool for creating AI-driven agents capable of handling complex workflows and multi-tool applications. It allows developers to create agents that can interact with large language models (LLMs), gather data, and perform tasks autonomously. By leveraging these agents, developers can automate various processes like information gathering, decision-making, and complex task execution.

### Real-world Example: Building an Autonomous Customer Service Agent
Imagine you're building a customer service agent for an e-commerce website. This agent can answer common customer queries (e.g., order status), search product databases, or even process refunds using different tools. This is similar to what LangGraph helps you build—an autonomous agent with multiple capabilities.

---

## Breakdown of the Code

The code provided is a simple example of how LangGraph can stream events and interact with the user to provide an AI response. Here's a detailed explanation of each part of the code:

```python
events = graph.stream(
    {
        "messages": [
            {
                "role": "user",
                "content": (
                    "Ya that's helpful. Maybe I'll "
                    "build an autonomous agent with it!"
                ),
            },
        ],
    },
    config,
    stream_mode="values",
)
```

### Line-by-Line Explanation:

- `events = graph.stream(...)`: This line initiates the streaming of events from the LangGraph framework. It's like opening a communication channel between the user and the AI. This is where the flow of messages begins.
  
- `messages`: This key holds the user message. Here, the user is indicating that the previous information was helpful and that they might build an autonomous agent using LangGraph.

- `"role": "user"`: Specifies that the message is from the user. This helps the system distinguish between user and AI messages.

- `"content": ...`: This is the actual message content. In this case, the user is sharing an idea about building an autonomous agent.

- `config`: This variable contains configuration settings that define how the graph should behave. These configurations could specify things like thread ID, checkpointing settings, or other parameters.

- `stream_mode="values"`: This specifies that the stream should emit values (i.e., responses and actions) rather than full events. It's a way of controlling the type of data returned.

---

```python
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

### Line-by-Line Explanation:

- `for event in events`: This loops over each event generated by the `graph.stream()` method. Each event represents a message or action in the LangGraph system.

- `if "messages" in event`: This checks if the current event contains any messages. If it does, it processes them further.

- `event["messages"][-1].pretty_print()`: This prints out the last message in the event, formatting it for better readability. The `pretty_print()` function is used to make the output easier to understand.

---

## Example Output:

When the above code runs, you'll see a series of messages printed out, such as:

```
================================== Human Message ===================================
Ya that's helpful. Maybe I'll build an autonomous agent with it!
================================== Ai Message ===================================
[{'text': "That's an exciting idea! Building an autonomous agent with LangGraph is indeed a great application of this technology...", 'type': 'text'}, {'id': 'toolu_01QWNHhUaeeWcGXvA4eHT7Zo', 'input': {'query': 'Building autonomous agents with LangGraph examples and tutorials'}, 'name': 'tavily_search_results_json', 'type': 'tool_use'}]
Tool Calls:
  tavily_search_results_json (toolu_01QWNHhUaeeWcGXvA4eHT7Zo)
  Call ID: toolu_01QWNHhUaeeWcGXvA4eHT7Zo
```

---

## Real-world Use Case Example

### Building Autonomous Agents for Customer Support

Imagine you're developing a virtual assistant for customer support. The virtual assistant must handle user queries, search for relevant product information, and even take actions like placing orders or processing returns. This involves integrating multiple tools like:

- **Search Tools**: For fetching product information.
- **Order Management Tools**: To manage and place orders.
- **Text Generation**: To generate natural language responses.

LangGraph can help coordinate these tools and manage the entire workflow in a seamless manner. For example:

1. **User Query**: The user might ask, "Where is my order?"
2. **LangGraph Workflow**: The agent identifies that it needs to fetch the order status from the database (using a tool like `order_status_query`).
3. **Response**: After getting the order status, the AI generates a natural language response and sends it back to the user.

This process can be handled by LangGraph, allowing your autonomous agent to work efficiently and autonomously.

---

## Replay Feature for Agent States

LangGraph also provides a replay mechanism where you can revisit the agent's state at any given time. Here's how it works:

```python
to_replay = None
for state in graph.get_state_history(config):
    print("Num Messages: ", len(state.values["messages"]), "Next: ", state.next)
    print("-" * 80)
    if len(state.values["messages"]) == 6:
        # We are somewhat arbitrarily selecting a specific state based on the number of chat messages in the state.
        to_replay = state
```

### Line-by-Line Explanation:

- `for state in graph.get_state_history(config)`: This loops through the history of the agent's states (which might include previous messages, tool calls, etc.).

- `if len(state.values["messages"]) == 6`: This checks if the state contains exactly 6 messages, and if so, selects it as the state to replay.

- `to_replay = state`: Saves the chosen state for future replay. This allows you to rewind to a particular state in the agent's history.

---

## Conclusion

LangGraph enables the creation of autonomous agents capable of handling multiple tasks and using various tools. By understanding the event streaming, message handling, and state replay features, you can build intelligent agents for a wide range of applications, from customer support to complex AI-driven workflows. The provided code snippets illustrate how LangGraph can be used to interact with users and maintain a history of actions and responses, ensuring smooth, autonomous decision-making.

# ⏳ Time Travel in LangGraph: Rewinding and Resuming State

Time travel in LangGraph lets you **rewind** your chatbot's state to a previous checkpoint and **resume** execution from that point. This is extremely useful for exploring alternative outcomes, debugging, or correcting mistakes without starting over from scratch.

Below, we'll break down the code and concepts in detail, explain each line, and provide real-world examples.

---

## 🔍 **Concept Overview**

- **Time Travel:**  
  Allows you to jump back to a previous state (checkpoint) in your application's history.  
- **Use Cases:**  
  - **Debugging:** Rewind to see where an error occurred.  
  - **Experimentation:** Explore different outcomes without losing previous work.  
  - **Interactive Applications:** Let users “undo” actions or branch off a different decision path.

**Real-World Example:**  
Imagine a digital storytelling platform where a reader can rewind the story to a previous chapter and choose an alternate path. Similarly, in autonomous software development, if an AI agent takes a wrong decision, the system can rewind to an earlier state, allowing the developer to try a different strategy.

---

## 🚀 **Code Walkthrough: Rewinding and Resuming Execution**

### **Step 1: Sending a New User Query**

The following code snippet simulates a chat session where a user makes a statement about building an autonomous agent.

```python
events = graph.stream(
    {
        "messages": [
            {
                "role": "user",
                "content": (
                    "Ya that's helpful. Maybe I'll "
                    "build an autonomous agent with it!"
                ),
            },
        ],
    },
    config,
    stream_mode="values",
)
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

#### **Explanation:**
- **`graph.stream(...)`**  
  - This function sends a message into the graph and initiates the chatbot’s response.
  - **Arguments:**  
    - **First Argument:** A dictionary with `"messages"` containing the user’s input.
    - **`config`:** A configuration object (e.g., containing a thread ID) that links this session to a specific conversation history.
    - **`stream_mode="values"`:** Specifies the format of the output.
- **Loop through events:**  
  - For every event returned by the graph, we check if it contains `"messages"`.  
  - **`event["messages"][-1].pretty_print()`:**  
    - This prints the latest message in a human-readable format.

**Output:**  
- **Human Message:**  
  "Ya that's helpful. Maybe I'll build an autonomous agent with it!"
- **AI Response:**  
  The AI acknowledges the idea, provides encouraging feedback, and makes a tool call to search for resources on building autonomous agents.

---

### **Step 2: Replaying the State History**

After several interactions, we can review the state history of the conversation. This history contains every checkpoint (i.e., every saved state of the conversation).

```python
to_replay = None
for state in graph.get_state_history(config):
    print("Num Messages: ", len(state.values["messages"]), "Next: ", state.next)
    print("-" * 80)
    if len(state.values["messages"]) == 6:
        # We arbitrarily choose a state based on the number of messages.
        to_replay = state
```

#### **Explanation:**
- **`graph.get_state_history(config)`**  
  - Fetches a list of all saved states (checkpoints) for the current conversation thread.
- **Loop through each state:**  
  - **`len(state.values["messages"])`:**  
    - Counts the number of messages in that state.
  - **`state.next`:**  
    - Indicates which node (or action) will be executed next.
  - We print these details to see the progress.
- **Selecting a state to replay:**  
  - We set `to_replay` to the state where there are exactly 6 messages. This is an arbitrary choice to illustrate rewinding to a particular checkpoint.

**Real-World Use Case:**  
In an autonomous vehicle system, checkpoints could record sensor data and decisions. If a wrong turn is taken, engineers can replay the state history to see at which checkpoint the error occurred.

---

### **Step 3: Inspecting the Selected Checkpoint**

We print out details from the selected state to verify its configuration.

```python
print(to_replay.next)
print(to_replay.config)
```

#### **Explanation:**
- **`to_replay.next`**  
  - Shows which node is scheduled to run next (e.g., `"tools"`).
- **`to_replay.config`**  
  - Displays the configuration (like thread ID and checkpoint ID) for that checkpoint.
  
*Output Example:*  
- Next node: `('tools',)`
- Configuration: `{'configurable': {'thread_id': '1', 'checkpoint_ns': '', 'checkpoint_id': '1efd43e3-0c1f-6c4e-8006-891877d65740'}}`

This tells us that the checkpoint has a specific **checkpoint_id** that we can use to resume execution from that point.

---

### **Step 4: Resuming Execution from a Checkpoint**

Finally, we resume the chatbot’s execution from the selected checkpoint.

```python
# The `checkpoint_id` in the `to_replay.config` corresponds to a state we've persisted.
for event in graph.stream(None, to_replay.config, stream_mode="values"):
    if "messages" in event:
        event["messages"][-1].pretty_print()
```

#### **Explanation:**
- **`graph.stream(None, to_replay.config, stream_mode="values")`**  
  - We pass `None` as the first argument because we're not sending a new message—instead, we want to resume from the stored state.
  - **`to_replay.config`**:  
    - Contains the checkpoint ID that tells the system to load the state from that specific moment.
- **Looping and printing messages:**  
  - We iterate over the events (i.e., the resumed conversation) and print the latest message.

**Output:**  
- The system will replay the actions from the checkpoint, starting from the `"tools"` node, and display the corresponding AI messages.

**Real-World Example:**  
In interactive storytelling, a reader might rewind to a previous chapter. The system then resumes from that chapter, allowing the reader to choose a different storyline. Similarly, in software debugging, you might rewind to a known good state and try a different fix.

---

## 🔑 **Key Takeaways**

- **Time Travel:**  
  Lets you rewind and resume from a previous state using checkpointing.
  
- **State History:**  
  You can review the complete history of the conversation to understand the evolution of your chatbot's responses.

- **Rewinding:**  
  Using a specific checkpoint (identified by a checkpoint ID) allows you to branch off or correct the workflow.

- **Real-World Applications:**  
  - **Autonomous Agents:** Debug and refine decision paths.
  - **Interactive Storytelling:** Let users explore alternative narratives.
  - **Software Debugging:** Rewind to earlier states to test different fixes.

---

## 🎉 **Conclusion**

By leveraging time travel in LangGraph, you gain powerful control over your application's state. You can rewind to previous checkpoints, explore different outcomes, and even fix mistakes—all without starting over. This opens up a myriad of possibilities for debugging, interactive user experiences, and robust, autonomous systems.

Feel free to experiment with this feature to see how it can enhance your projects!