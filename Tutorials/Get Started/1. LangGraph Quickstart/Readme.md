# 🚀 **LangGraph Quickstart: Building a Smart Chatbot**  

LangGraph is a powerful framework that allows you to build stateful, interactive AI applications. In this guide, we will create a **support chatbot** that can:  

✅ Answer common questions by searching the web  
✅ Maintain conversation history across calls  
✅ Route complex queries to a human  
✅ Use custom states to control behavior  
✅ Rewind and explore alternative conversation paths  

We will start with a **basic chatbot** and gradually **add advanced capabilities** while explaining every step in detail. Let’s dive in! 🌟  

---

# 🛠 **1. Setup: Installing Required Packages**  

Before we begin, let's **install the required dependencies** and configure our environment.

### 📌 **Step 1: Install LangGraph and Required Packages**  
Run the following command to install **LangGraph**, **LangSmith**, and **LangChain Anthropic**:

```python
%%capture --no-stderr
%pip install -U langgraph langsmith langchain_anthropic
```
📌 **Explanation:**  
- `%pip install -U` → Installs the latest version of the specified libraries.  
- `langgraph` → The core library for building AI-driven state machines.  
- `langsmith` → A debugging and monitoring tool for LangGraph apps.  
- `langchain_anthropic` → Integrates with **Anthropic's LLMs** (Claude models).  

### 📌 **Step 2: Configure Environment Variables**  
We need to **set API keys** for using Anthropic's language model.  

```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):  # If the variable is not set
        os.environ[var] = getpass.getpass(f"{var}: ")  # Prompt user to enter it

_set_env("ANTHROPIC_API_KEY")  # Set API key
```

📌 **Explanation:**  
- `os.environ.get(var)` → Checks if the environment variable exists.  
- `getpass.getpass(f"{var}: ")` → Securely prompts the user for input.  
- `_set_env("ANTHROPIC_API_KEY")` → Calls the function to set the API key for Anthropic.  

---

# 🤖 **2. Building a Basic Chatbot with LangGraph**  

Now that we have set up the environment, let’s **create a simple chatbot** using **LangGraph**.

### 📌 **Step 1: Define the Chatbot's State**  

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages

class State(TypedDict):
    messages: Annotated[list, add_messages]  # Maintain a list of messages
```

📌 **Explanation:**  
- `TypedDict` → Defines a **dictionary-like** structure for chatbot state.  
- `messages: Annotated[list, add_messages]` →  
  - Stores messages as a **list**.  
  - Uses `add_messages`, which **appends** messages instead of overwriting them.  

---

### 📌 **Step 2: Create a StateGraph (Chatbot Logic)**  

```python
graph_builder = StateGraph(State)  # Define a new StateGraph
```

📌 **Explanation:**  
- `StateGraph(State)` → Creates a **state machine** for our chatbot.  
- This graph will **control how messages flow** through the chatbot.  

---

## 🛠 **How Our Chatbot Works (Graph Logic)**  

🔹 **Each node** in the graph represents a **function** that can process messages.  
🔹 **Edges** define how the bot **transitions** between functions.  
🔹 Messages **persist** across interactions using the **add_messages** function.  

---

## ✅ **What’s Next?**  
Now that we've **built the foundation**, we can:  
1. Add **message-processing functions**.  
2. Implement **AI-powered responses** using LangChain.  
3. Introduce **advanced features** like human handoff and state control.  

Let me know if you want to continue building the chatbot step by step! 🚀

# 🚀 **Building a Chatbot with LangGraph: A Step-by-Step Guide**  

In this guide, we will **add intelligence** to our chatbot using **LangGraph** by integrating a **chatbot node** and enabling **user interactions**. By the end, you will have a fully functional **AI chatbot** capable of responding to user queries.  

---

# 🛠 **1. Adding a Chatbot Node 🤖**  

### 📌 **What is a Node?**  
A **node** in LangGraph represents a **unit of work**. It is simply a **Python function** that processes **state** and returns **an updated state**.  

### 📌 **Step 1: Import and Initialize the Language Model (LLM)**  

```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")  # Load the LLM model
```

📌 **Explanation:**  
- `ChatAnthropic` → Loads **Anthropic's Claude-3.5 Sonnet** model.  
- `model="claude-3-5-sonnet-20240620"` → Specifies the **model version**.  
- `llm` is now ready to **generate responses** for user queries.  

---

### 📌 **Step 2: Create the Chatbot Node**  

```python
def chatbot(state: State):
    return {"messages": [llm.invoke(state["messages"])]}
```

📌 **Explanation:**  
- `state: State` → The chatbot **receives** the current conversation **state**.  
- `state["messages"]` → Retrieves **past messages** stored in the chatbot's memory.  
- `llm.invoke(state["messages"])` → Sends **messages** to the **LLM** and gets a response.  
- `return {"messages": [...]}` → Returns an **updated** messages list in **dictionary format**.  

💡 **Key Concept:**  
- The **LLM processes** the user’s **message history** and **generates** a **reply**.  

---

### 📌 **Step 3: Register the Node in the Graph**  

```python
graph_builder.add_node("chatbot", chatbot)
```

📌 **Explanation:**  
- `add_node("chatbot", chatbot)` → Adds a node named `"chatbot"` that runs the `chatbot()` function.  
- Whenever this node is **triggered**, it will execute **our chatbot function**.  

---

# 🏁 **2. Defining the Flow of the Chatbot**  

Now that we have a chatbot node, we need to **define how the conversation flows**.

### 📌 **Step 1: Set the Starting Point 🚀**  

```python
graph_builder.add_edge(START, "chatbot")
```

📌 **Explanation:**  
- `add_edge(START, "chatbot")` → Tells LangGraph **where to begin** execution.  
- Every time we **start the chatbot**, it will **execute the chatbot node** first.  

---

### 📌 **Step 2: Define the Ending Point 🛑**  

```python
graph_builder.add_edge("chatbot", END)
```

📌 **Explanation:**  
- `add_edge("chatbot", END)` → Defines when the chatbot **stops execution**.  
- After the chatbot **processes** a message, it **ends the current execution cycle**.  

💡 **Key Concept:**  
- This ensures that **each message** is processed **individually** rather than creating an infinite loop.  

---

# 🔧 **3. Compiling and Running the Chatbot**  

Now that we have defined the chatbot logic, let's **compile** and **run** it.

### 📌 **Step 1: Compile the Graph**  

```python
graph = graph_builder.compile()
```

📌 **Explanation:**  
- `compile()` → Converts our **graph structure** into a **compiled executable graph**.  
- `graph` is now **ready to run** and **process messages**.  

---

### 📌 **Step 2: Visualize the Graph (Optional) 🖼️**  

```python
from IPython.display import Image, display

try:
    display(Image(graph.get_graph().draw_mermaid_png()))
except Exception:
    pass  # Skip if visualization dependencies are missing
```

📌 **Explanation:**  
- `graph.get_graph().draw_mermaid_png()` → Generates a **visual graph**.  
- This helps us **see** the chatbot’s **workflow**.  

💡 **Tip:** If you face errors, ensure you have the **required dependencies** installed.  

---

# 💬 **4. Running the Chatbot in a Chat Loop**  

Now, let's allow the user to **interact** with our chatbot **in real-time**.  

### 📌 **Step 1: Function to Handle Chat Messages**  

```python
def stream_graph_updates(user_input: str):
    for event in graph.stream({"messages": [{"role": "user", "content": user_input}]}):
        for value in event.values():
            print("Assistant:", value["messages"][-1].content)
```

📌 **Explanation:**  
- `graph.stream(...)` → Sends **user input** to the chatbot and **streams responses**.  
- `{"role": "user", "content": user_input}` → **Formats** user input for the LLM.  
- `event.values()` → Iterates over **all responses** from the chatbot.  
- `print("Assistant:", value["messages"][-1].content)` → Prints the **latest chatbot response**.  

💡 **Key Concept:**  
- This function allows the chatbot to **process messages in real-time**.  

---

### 📌 **Step 2: Implementing a Continuous Chat Loop 🔁**  

```python
while True:
    try:
        user_input = input("User: ")  # Get user input
        if user_input.lower() in ["quit", "exit", "q"]:  # Exit condition
            print("Goodbye!")
            break

        stream_graph_updates(user_input)  # Process user input
    except:
        # Fallback in case input() is unavailable
        user_input = "What do you know about LangGraph?"
        print("User: " + user_input)
        stream_graph_updates(user_input)
        break
```

📌 **Explanation:**  
- `while True:` → Runs an **infinite loop** to keep the chatbot active.  
- `user_input = input("User: ")` → Gets **user input** from the console.  
- `if user_input.lower() in ["quit", "exit", "q"]:` → Allows the user to **exit** the chat.  
- `stream_graph_updates(user_input)` → Sends the **user input** to the chatbot and **prints the response**.  
- `except:` → Handles cases where `input()` might not work (e.g., **non-interactive environments**).  

💡 **Key Concept:**  
- This code keeps the **chat running** until the user **chooses to exit**.  

---

# 🎉 **5. Congratulations! Your Chatbot is Ready!**  

✅ **What We Built:**  
- A chatbot using **LangGraph** and **Anthropic Claude-3.5**.  
- A **stateful system** where past messages are **retained**.  
- A chatbot that can **process user inputs** in real-time.  
- A **chat loop** to allow ongoing conversation.  

✅ **Next Steps:**  
- Improve the chatbot by **adding search capabilities**.  
- Integrate **memory and context awareness**.  
- Allow **multi-turn conversations** with better state management.  

---

💡 **Want to Learn More?** Let me know if you want to add more features like **web search**, **human handoff**, or **better memory management**! 🚀

Here's a detailed and beginner-friendly explanation of the provided content, with structured headings, icons, and line-by-line code explanations.  

---

# 🚀 Enhancing the Chatbot with Web Search 🛠️  

Our chatbot currently relies on its built-in knowledge, which is limited to its training data. In this section, we will enhance it by integrating a **web search tool** that will allow it to find and provide real-time information from the internet.

---

## 📌 Why Add a Web Search Tool?  

- 🤖 **Improves chatbot knowledge**: The bot will be able to answer questions that are not part of its pre-trained data.  
- 🌐 **Fetches up-to-date information**: Since AI models are trained on past data, this allows the bot to search for the latest updates.  
- 🔍 **Better user experience**: Users get more accurate and relevant responses.

---

# 🛠️ Step 1: Install Required Packages  

Before we proceed, let's install the necessary Python packages.  

### ✅ Install Dependencies  

We need the following:  
- `tavily-python`: Provides a web search API.  
- `langchain_community`: Helps integrate tools with LangChain.  

📌 **Run the following command to install the required packages:**  

```python
%%capture --no-stderr
%pip install -U tavily-python langchain_community
```

📌 **Explanation:**  
- `%%capture --no-stderr`: Suppresses unnecessary warnings/errors.  
- `%pip install -U`: Upgrades and installs the required packages.  
- `tavily-python`: Allows the chatbot to search the web.  
- `langchain_community`: Provides integration tools for LangChain.  

---

# 🔑 Step 2: Set API Key for Tavily Search  

To use the **Tavily Search Engine**, we need an API key.  

```python
_set_env("TAVILY_API_KEY")

TAVILY_API_KEY:  ········  # (You need to replace this with your actual API key)
```

📌 **Explanation:**  
- `_set_env("TAVILY_API_KEY")`: Saves the API key as an environment variable for secure access.  
- `TAVILY_API_KEY`: This will be used by our chatbot to authenticate requests to Tavily.

---

# 🔍 Step 3: Define the Web Search Tool  

Now, let's integrate the **Tavily search tool** so that the chatbot can fetch real-time information.  

### ✅ Create the Search Tool  

```python
from langchain_community.tools.tavily_search import TavilySearchResults

tool = TavilySearchResults(max_results=2)
tools = [tool]
```

📌 **Explanation:**  
- `TavilySearchResults(max_results=2)`: Creates a tool that fetches web search results, limiting it to **2 results**.  
- `tools = [tool]`: Stores the tool in a list so we can easily pass it to the chatbot later.

### ✅ Test the Web Search Tool  

We can check if the tool works by running:  

```python
tool.invoke("What's a 'node' in LangGraph?")
```

📌 **Expected Output:**  
The chatbot will return a list of URLs and content summaries from the web, such as:  

```json
[
  {
    "url": "https://medium.com/@cplog/introduction-to-langgraph-a-beginners-guide-14f9be027141",
    "content": "Nodes: Nodes are the building blocks of your LangGraph..."
  },
  {
    "url": "https://saksheepatil05.medium.com/demystifying-langgraph...",
    "content": "Nodes (Tasks): Nodes are like the workstations on the assembly line..."
  }
]
```

---

# 🏗️ Step 4: Define the Chatbot Graph  

Now, we will build a **state graph** for the chatbot using LangGraph.  

### ✅ Define the Chatbot State  

```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from typing_extensions import TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages

class State(TypedDict):
    messages: Annotated[list, add_messages]
```

📌 **Explanation:**  
- `State(TypedDict)`: Defines a dictionary structure for storing messages.  
- `messages: Annotated[list, add_messages]`: A list that will hold chat history.  

---

### ✅ Create the Graph  

```python
graph_builder = StateGraph(State)
```

📌 **Explanation:**  
- `StateGraph(State)`: Initializes a graph structure where **each node represents a step in our chatbot’s logic**.

---

### ✅ Initialize the Language Model  

```python
llm = ChatAnthropic(model="claude-3-5-sonnet-20240620")
# Modification: tell the LLM which tools it can call
llm_with_tools = llm.bind_tools(tools)
```

📌 **Explanation:**  
- `ChatAnthropic(model="claude-3-5-sonnet-20240620")`: Loads the **Claude 3.5 Sonnet** AI model for processing messages.  
- `llm_with_tools = llm.bind_tools(tools)`: Allows the chatbot to use the **web search tool** whenever needed.

---

### ✅ Create the Chatbot Node  

```python
def chatbot(state: State):
    return {"messages": [llm_with_tools.invoke(state["messages"])]}

graph_builder.add_node("chatbot", chatbot)
```

📌 **Explanation:**  
- `def chatbot(state: State)`: Defines a function that takes the **current chat state** as input.  
- `llm_with_tools.invoke(state["messages"])`:  
  - If the LLM can answer from memory, it does.  
  - If not, it **calls the web search tool**.  
- `graph_builder.add_node("chatbot", chatbot)`: Adds a **"chatbot" node** to the state graph.

---

# 🔄 Step 5: Define Entry & Exit Points  

We must specify **where the graph starts and ends**.  

### ✅ Set the Starting Point  

```python
graph_builder.add_edge(START, "chatbot")
```

📌 **Explanation:**  
- `START`: The **entry point** of the chatbot workflow.  
- `"chatbot"`: The chatbot node where execution begins.

### ✅ Set the Finishing Point  

```python
graph_builder.add_edge("chatbot", END)
```

📌 **Explanation:**  
- `"chatbot"`: The chatbot node finishes execution.  
- `END`: The **exit point** of the workflow.

---

# ▶️ Step 6: Run the Chatbot  

### ✅ Compile the Graph  

```python
graph = graph_builder.compile()
```

📌 **Explanation:**  
- `graph_builder.compile()`: Converts the graph into a **fully executable chatbot**.

---

# 🖼️ Step 7: Visualize the Graph  

If we want to visualize the chatbot's logic:  

```python
from IPython.display import Image, display

try:
    display(Image(graph.get_graph().draw_mermaid_png()))
except Exception:
    pass
```

📌 **Explanation:**  
- `graph.get_graph().draw_mermaid_png()`: Generates a **graph visualization**.  
- `display(Image(...))`: Displays the chatbot’s logic flow.  

---

# 💬 Step 8: Test the Chatbot  

```python
def stream_graph_updates(user_input: str):
    for event in graph.stream({"messages": [{"role": "user", "content": user_input}]}):
        for value in event.values():
            print("Assistant:", value["messages"][-1].content)

while True:
    try:
        user_input = input("User: ")
        if user_input.lower() in ["quit", "exit", "q"]:
            print("Goodbye!")
            break
        stream_graph_updates(user_input)
    except:
        user_input = "What do you know about LangGraph?"
        print("User: " + user_input)
        stream_graph_updates(user_input)
        break
```

📌 **Explanation:**  
- `while True`: Keeps the chatbot running in a loop.  
- `input("User: ")`: Takes user input.  
- `stream_graph_updates(user_input)`:  
  - Calls the chatbot.  
  - Prints the AI's response.  
- `"quit", "exit", "q"`: Exits the chatbot.

---

# 🎉 Conclusion  

✅ We have successfully **enhanced the chatbot** with web search!  
📌 Now, the bot can provide **real-time information** using the **Tavily Search Engine**.  

Would you like to extend this chatbot further? 🚀

# 🚀 Enhancing the Chatbot with Tools (Deep Explanation)  

In this section, we will **enhance our chatbot** by integrating **tool invocation** so that it can handle **queries beyond its training data**. This is essential for making the chatbot **more dynamic and capable** of providing up-to-date information.  

## 📌 What We Will Learn:  
1. **Why we need tools** for handling chatbot queries.  
2. **How to create a tool execution node** (`BasicToolNode`).  
3. **How to route chatbot responses** based on whether a tool was used.  
4. **How to define conditional edges** in a chatbot graph.  
5. **How to visualize our chatbot's decision flow.**  

---

## 🛠️ Step 1: Creating a Tool Execution Node  

### 🤔 Why Do We Need This?  
A chatbot by itself **can only respond based on its memory** (i.e., pre-trained knowledge). However, real-world queries often require **external information**, such as fetching live news, stock prices, or definitions.  

To solve this problem, we create a **tool execution node**, which:  
- **Checks the chatbot's last message** to see if it requested a tool.  
- **Finds the correct tool** and executes it.  
- **Returns the tool's output** as a response.  

---

### ✅ **Code Implementation: Creating `BasicToolNode`**  

```python
import json
from langchain_core.messages import ToolMessage

class BasicToolNode:
    """A node that runs the tools requested in the last AIMessage."""

    def __init__(self, tools: list) -> None:
        # Store tools in a dictionary with their names as keys for quick lookup
        self.tools_by_name = {tool.name: tool for tool in tools}

    def __call__(self, inputs: dict):
        # Retrieve the last message from the state
        if messages := inputs.get("messages", []):
            message = messages[-1]
        else:
            raise ValueError("No message found in input")

        outputs = []
        
        # Check if the chatbot requested any tool calls
        for tool_call in message.tool_calls:
            tool_result = self.tools_by_name[tool_call["name"]].invoke(tool_call["args"])
            
            # Convert the tool's output into a message format
            outputs.append(
                ToolMessage(
                    content=json.dumps(tool_result),  # Convert tool output to JSON string
                    name=tool_call["name"],  # Store the tool's name
                    tool_call_id=tool_call["id"],  # Store tool's ID
                )
            )
        
        return {"messages": outputs}

# Creating an instance of BasicToolNode with our tools
tool_node = BasicToolNode(tools=[tool])

# Add this node to our chatbot graph
graph_builder.add_node("tools", tool_node)
```

### 🔍 **Code Breakdown:**
1. **`__init__(self, tools: list) -> None`:**  
   - Stores tools in a dictionary for **quick lookup**.  

2. **`__call__(self, inputs: dict)`:**  
   - **Retrieves the latest chatbot message** to check if a tool was requested.  
   - If a tool is needed, it **calls the appropriate tool**.  
   - The result is **converted into a `ToolMessage` object** and returned.  

3. **Adding `BasicToolNode` to `graph_builder`:**  
   - This ensures our chatbot **can use the tool when needed**.  

---

## 🔄 Step 2: Routing Chatbot Responses with Conditional Edges  

### ❓ Why Do We Need This?  
Now that our chatbot **can call tools**, we need to decide:  
- **If a tool was requested**, **redirect the chatbot to `tools`** so it can fetch data.  
- **If no tool was needed**, **end the conversation**.  

To do this, we define a **router function** that checks for tool requests and **guides the chatbot accordingly**.  

---

### ✅ **Code Implementation: Defining `route_tools`**  

```python
def route_tools(state: State):
    """
    Route to the tool node if the last message has tool calls.
    Otherwise, route to END.
    """
    if isinstance(state, list):
        ai_message = state[-1]
    elif messages := state.get("messages", []):
        ai_message = messages[-1]
    else:
        raise ValueError(f"No messages found in input state to tool_edge: {state}")

    # If the last message contains tool calls, go to "tools" node
    if hasattr(ai_message, "tool_calls") and len(ai_message.tool_calls) > 0:
        return "tools"
    
    # Otherwise, end the chatbot's response
    return END
```

### 🔍 **Code Breakdown:**
1. **Retrieve the last chatbot message** from the state.  
2. **Check if the message includes tool calls**:  
   - If `tool_calls` exist → **Go to `"tools"` node**.  
   - If no tool is needed → **End the conversation (`END`)**.  

---

## 🏗️ Step 3: Adding Conditional Edges  

### ✅ **Code Implementation: Adding `route_tools` to the Chatbot Graph**  

```python
graph_builder.add_conditional_edges(
    "chatbot",  # From chatbot node
    route_tools,  # Use route_tools function to decide next step
    {
        "tools": "tools",  # If tools are needed, go to "tools" node
        END: END  # Otherwise, stop the chatbot
    },
)

# Ensure the chatbot returns to itself after using a tool
graph_builder.add_edge("tools", "chatbot")

# Start the chatbot at the "chatbot" node
graph_builder.add_edge(START, "chatbot")

# Compile the chatbot graph
graph = graph_builder.compile()
```

### 🔍 **Code Breakdown:**
1. **`add_conditional_edges`**
   - Uses `route_tools` to **determine where to go next**:
     - `"tools"` → Call tool if needed.
     - `"END"` → Stop if no tool is needed.

2. **Adding Edges to Keep the Chatbot Running**
   - `"tools"` → `"chatbot"` → Ensures the chatbot **resumes conversation after tool execution**.
   - `START → chatbot` → Defines the **starting point**.

---

## 📊 Step 4: Visualizing the Chatbot's Decision Flow  

### ✅ **Code Implementation: Generating a Flowchart**  

```python
from IPython.display import Image, display

try:
    display(Image(graph.get_graph().draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass
```

### 📌 **What This Does:**
- **Displays a visual representation** of the chatbot's decision-making process.  
- **Shows how messages move between nodes** (`chatbot` → `tools` → `chatbot` OR `END`).  

---

## 🎯 Summary  

### ✅ **What We Achieved:**
1. **Created a Tool Execution Node (`BasicToolNode`)** 🛠️  
   - Handles **tool requests** from chatbot responses.  

2. **Defined a Router Function (`route_tools`)** 🔀  
   - **Checks if tools are needed** and **routes** the chatbot accordingly.  

3. **Added Conditional Edges** 🏗️  
   - Ensures the chatbot **knows when to use tools** and **when to stop**.  

4. **Visualized the Chatbot’s Decision Flow** 📊  
   - Helps **understand how the chatbot makes decisions**.  

---

## 🚀 Next Steps  
- **Replace `BasicToolNode` with a prebuilt `ToolNode`** for efficiency.  
- **Expand chatbot functionality** by integrating **multiple tools**.  

This enhancement **makes our chatbot smarter** by **fetching real-time information**, making it **more dynamic and useful!** 🎉