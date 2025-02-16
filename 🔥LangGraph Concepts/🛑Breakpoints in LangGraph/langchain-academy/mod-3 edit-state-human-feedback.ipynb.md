# 🚀 **Editing Graph State in Human-in-the-Loop Systems**  

In this guide, we will deeply explore **graph state editing** in a **human-in-the-loop (HITL) system**. We'll cover:  

- 🔍 **Why human-in-the-loop is important?**  
- 🛠 **How to interrupt and modify the graph state?**  
- 📝 **How to use breakpoints for user approval?**  
- 💡 **Real-world applications of this concept**  
- 🖥 **Code examples with detailed explanations**  

---

## 🧠 **Why Human-in-the-Loop (HITL)?**  

Human-in-the-loop systems **combine AI automation with human decision-making** to ensure correctness, improve reliability, and allow manual intervention when needed.  

Here’s **why HITL is useful**:  

1️⃣ **✅ Approval**: Allows users to approve or reject AI-generated actions before execution.  
2️⃣ **🐞 Debugging**: Users can rewind, inspect, and modify the graph state to troubleshoot errors.  
3️⃣ **✏️ Editing**: Users can directly modify system behavior by altering the graph state.  

---

## 🌐 **Real-World Applications of Graph State Editing**  

📌 **Chatbots & Virtual Assistants**: Users can **review AI-generated responses** before sending them.  
📌 **Automated Decision Systems**: In **finance, medical AI, or legal AI**, humans can **validate** decisions.  
📌 **AI Debugging Tools**: Developers can **pause AI workflows, inspect states, and modify them** to fix errors.  
📌 **Process Automation**: Businesses can **modify workflow logic dynamically** based on real-time user feedback.  

---

## 🔥 **How to Edit Graph State in LangGraph**  

We'll now demonstrate **how to modify the graph state dynamically** using Python and LangGraph.

### 1️⃣ **Installing Required Libraries**  

```python
%%capture --no-stderr
%pip install --quiet -U langgraph langchain_openai langgraph_sdk
```

📌 **What this does?**  
- `pip install --quiet -U ...` → Installs or upgrades required libraries.  
- `%%capture --no-stderr` → Suppresses unnecessary output while running the command.  

---

### 2️⃣ **Setting Up Environment Variables**  

```python
import os, getpass

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("OPENAI_API_KEY")
```

📌 **What this does?**  
- We define `_set_env()` to **set environment variables securely** (e.g., API keys).  
- If `"OPENAI_API_KEY"` is **not already set**, it prompts the user to enter it.  

🔹 This ensures that **API keys are not hardcoded** and remain secure.  

---

### 3️⃣ **Using Breakpoints to Modify Graph State**  

We use **breakpoints** to **interrupt AI execution** and allow users to edit state before proceeding.  

#### 📌 **Example: Math Operations with AI**  

```python
from langchain_openai import ChatOpenAI

def multiply(a: int, b: int) -> int:
    """Multiply a and b."""
    return a * b

def add(a: int, b: int) -> int:
    """Adds a and b."""
    return a + b

def divide(a: int, b: int) -> float:
    """Divide a by b."""
    return a / b

tools = [add, multiply, divide]
llm = ChatOpenAI(model="gpt-4o")
llm_with_tools = llm.bind_tools(tools)
```

📌 **What this does?**  
- Defines **three basic math functions**: `add()`, `multiply()`, and `divide()`.  
- `tools = [add, multiply, divide]` → Creates a **list of tools** for the AI model.  
- `llm = ChatOpenAI(model="gpt-4o")` → Initializes a **GPT-4o model**.  
- `llm_with_tools = llm.bind_tools(tools)` → Binds **math tools to the AI model**, allowing the model to use them dynamically.  

---

## 🎯 **Key Takeaways**  

✔️ **Breakpoints enable user intervention** in AI workflows.  
✔️ **Graph state can be modified** dynamically, allowing real-time adjustments.  
✔️ **LangGraph integrates AI with human feedback**, making AI workflows **more reliable and explainable**.  
✔️ **Real-world applications** include **chatbots, automated decision systems, AI debugging tools, and process automation**.  

Would you like me to add more **detailed explanations** or **expand on real-world applications**? 🚀


---

# 🚀 **Understanding Graph State Editing with LangGraph**  

Graph-based workflows are powerful tools in AI and automation. This guide will **explain in-depth** how to **interrupt, modify, and resume AI workflows** using **LangGraph**.  

---

# 📌 **Table of Contents**  
1️⃣ **What is Graph State Editing?**  
2️⃣ **Why is it Useful? (Real-World Examples)**  
3️⃣ **Understanding the Code Step-by-Step**  
4️⃣ **Breaking Down the Graph Execution Flow**  
5️⃣ **How Does the Interruption Work?**  
6️⃣ **Running the Graph and Inspecting State**  

---

## 🔍 **1. What is Graph State Editing?**  

Graph state editing allows us to **interrupt an AI workflow at specific points, inspect its state, and modify it before continuing**. This is particularly useful in AI-driven automation where human intervention is needed.  

For example, imagine you have a chatbot performing calculations. You may want to:  
✔️ **Approve the AI's calculations before they execute.**  
✔️ **Modify an AI-generated answer before it's shown to the user.**  
✔️ **Debug and track each step in an AI-powered workflow.**  

---

## 🌐 **2. Why is it Useful? (Real-World Examples)**  

📌 **🔎 AI Debugging**: If an AI system gives incorrect results, we can pause execution, inspect its state, and fix issues before continuing.  
📌 **✅ Approval in Automation**: Before an AI sends an email, books a flight, or makes a financial transaction, a human can **approve or modify** the decision.  
📌 **📢 AI Chatbots with Human Supervision**: In customer support chatbots, the AI can **pause before sending a response**, allowing a human agent to review and edit the message.  

---

# 🛠 **3. Understanding the Code Step-by-Step**  

### ✅ **Step 1: Import Required Libraries**  

```python
from IPython.display import Image, display
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import MessagesState, START, StateGraph
from langgraph.prebuilt import tools_condition, ToolNode
from langchain_core.messages import HumanMessage, SystemMessage
```

📌 **What This Does?**  
- `IPython.display.Image, display` → Helps visualize the graph.  
- `MemorySaver` → Saves checkpoints (allows rewinding the workflow).  
- `MessagesState` → Stores conversation messages.  
- `StateGraph` → Defines the structure of the AI workflow.  
- `tools_condition` → Decides whether AI should call a tool or stop.  
- `ToolNode` → Represents available tools (like calculator functions).  
- `HumanMessage, SystemMessage` → Represent user and system messages.  

---

### ✅ **Step 2: Define the AI Assistant's Behavior**  

```python
sys_msg = SystemMessage(content="You are a helpful assistant tasked with performing arithmetic on a set of inputs.")
```

📌 **What This Does?**  
- This creates a **system message** that tells the AI its role and objective.  

---

### ✅ **Step 3: Define the Assistant Node**  

```python
def assistant(state: MessagesState):
   return {"messages": [llm_with_tools.invoke([sys_msg] + state["messages"])]}
```

📌 **What This Does?**  
- The assistant **receives a state** (list of messages).  
- It calls the `llm_with_tools` AI model to process the messages.  
- The AI **returns a response** based on user input and system rules.  

---

### ✅ **Step 4: Define the Graph Workflow**  

```python
builder = StateGraph(MessagesState)
```

📌 **What This Does?**  
- Creates a **stateful graph** where each message in a conversation is stored as a state.  

---

### ✅ **Step 5: Add Processing Nodes**  

```python
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))
```

📌 **What This Does?**  
- `"assistant"` → Calls the AI assistant.  
- `"tools"` → Calls external tools (like a calculator).  

---

### ✅ **Step 6: Define Control Flow (Edges Between Nodes)**  

```python
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition,  # Routes to 'tools' if needed
)
builder.add_edge("tools", "assistant")
```

📌 **What This Does?**  
- The graph starts with `"assistant"`.  
- The `tools_condition` function **checks if the AI needs to call a tool** (e.g., a calculator).  
- If a tool is required, the AI calls `"tools"`, then loops back to `"assistant"`.  

---

### ✅ **Step 7: Enable Graph Interruption (User Can Edit State)**  

```python
memory = MemorySaver()
graph = builder.compile(interrupt_before=["assistant"], checkpointer=memory)
```

📌 **What This Does?**  
- **Interrupts the graph** before the `"assistant"` node runs.  
- **Saves checkpoints** using `MemorySaver()` so we can rewind or modify execution.  

---

### ✅ **Step 8: Visualizing the Graph**  

```python
display(Image(graph.get_graph(xray=True).draw_mermaid_png()))
```

📌 **What This Does?**  
- Generates a **visual representation** of the AI workflow graph.  

---

# 🎯 **4. Breaking Down the Graph Execution Flow**  

Let's now **run the graph** and see what happens step by step.  

---

### ✅ **Step 1: Define User Input and Create a Thread**  

```python
initial_input = {"messages": "Multiply 2 and 3"}
thread = {"configurable": {"thread_id": "1"}}
```

📌 **What This Does?**  
- `initial_input` → Represents user input (**Multiply 2 and 3**).  
- `thread` → Represents a **conversation instance**.  

---

### ✅ **Step 2: Run the Graph Until the First Interruption**  

```python
for event in graph.stream(initial_input, thread, stream_mode="values"):
    event['messages'][-1].pretty_print()
```

📌 **What This Does?**  
- Runs the graph **step by step** (until we reach an interruption).  
- `event['messages'][-1].pretty_print()` → Prints the last message from the conversation.  

---

### ✅ **Step 3: View and Modify State**  

```python
state = graph.get_state(thread)
state
```

📌 **What This Does?**  
- Retrieves the **current state** of the conversation.  
- This state **can be modified before resuming execution**.  

---

# 🔥 **5. How Does the Interruption Work?**  

The graph **pauses before the AI assistant responds**. This allows:  
✔️ **Humans to modify the input** (e.g., changing "Multiply" to "Add").  
✔️ **Developers to inspect state** (e.g., checking AI reasoning).  
✔️ **Debugging before continuing execution**.  

---

# 🚀 **6. Running the Graph and Inspecting State**  

When we run the code, we get:  

```
================================ Human Message =================================
Multiply 2 and 3
```

🔹 **The AI has not yet responded** because we interrupted execution before the `"assistant"` node.  

Now, if we modify the state before resuming, we can **change how the AI behaves**.  

---

# 🎯 **Key Takeaways**  

✔️ **Graph-based AI workflows enable structured, stateful execution.**  
✔️ **Interruptions allow human intervention before AI decisions execute.**  
✔️ **We can visualize and modify the AI's execution flow dynamically.**  
✔️ **Real-world applications include AI chatbots, decision-making systems, and automated workflows.**  

Would you like me to **add an example of modifying the state before resuming execution**? 🚀

---


# 🚀 Graph State Updates with LangGraph

Graph state updates allow us to **modify the conversation state on the fly**. This is particularly useful in workflows where human feedback is needed to correct or refine an AI’s actions before it continues. Let’s dive deep into this concept with detailed explanations and code examples.

---

# 🔍 What Is Graph State Updating?

Graph state updating enables you to **pause an AI workflow**, update its internal state (e.g., change user inputs or correct mistakes), and then resume execution from that updated state. This capability is essential for:

- **Correcting Errors**: Users can modify inputs or outputs if a mistake is noticed.
- **Debugging**: Developers can inspect and alter the state to understand or fix issues.
- **Human-In-The-Loop (HITL)**: A human operator can interact with and refine the AI’s decision-making process.

**Real-World Example**:  
Imagine a customer service chatbot that initially misinterprets a request. The user could correct it mid-conversation (e.g., changing “Multiply 2 and 3” to “No, actually multiply 3 and 3!”) before the system processes the request further.

---

# 🛠 Code Example: Updating the Graph State

Below is a code snippet that shows how to update the state of a graph in LangGraph. We assume that the conversation state contains a list of messages, and we use a reducer called `add_messages` which appends new messages unless an ID is provided.

```python
# Update the conversation state by appending a new message
graph.update_state(
    thread,
    {"messages": [HumanMessage(content="No, actually multiply 3 and 3!")]},
)
```

### Explanation of Each Line

- **`graph.update_state(`**  
  Initiates a state update on the current graph.  
  
- **`thread,`**  
  Specifies the conversation thread (i.e., the current session or context) whose state is being updated.

- **`{"messages": [...]}`**  
  Provides the update data. Here, we update the key `"messages"` in our state.

- **`[HumanMessage(content="No, actually multiply 3 and 3!")]`**  
  - We create a new `HumanMessage` with the updated content.  
  - **Note**: Because no ID is specified, the `add_messages` reducer will **append** this message to the existing list instead of replacing an existing one.

---

# 👀 Inspecting the Updated State

After updating the state, we can view it to confirm that our new message has been added:

```python
# Retrieve the current state of the conversation
new_state = graph.get_state(thread).values

# Iterate through all messages and print them in a pretty format
for m in new_state['messages']:
    m.pretty_print()
```

### Explanation of Each Line

- **`new_state = graph.get_state(thread).values`**  
  Retrieves the current state associated with the specified thread. The `.values` extracts the dictionary of state values.

- **`for m in new_state['messages']:`**  
  Loops through the list of messages stored under the key `"messages"`.

- **`m.pretty_print()`**  
  Nicely prints each message. You should see output similar to:
  
  ```
  ================================= Human Message =================================
  Multiply 2 and 3
  ================================= Human Message =================================
  No, actually multiply 3 and 3!
  ```

This confirms that our new message has been appended to the conversation state.

---

# ⏭ Resuming the Graph Execution

Once the state is updated, we can resume execution. We do this by streaming the graph without providing new input, allowing it to continue from the current state:

```python
for event in graph.stream(None, thread, stream_mode="values"):
    event['messages'][-1].pretty_print()
```

### Explanation of Each Line

- **`for event in graph.stream(None, thread, stream_mode="values"):`**  
  This loop resumes the graph execution:
  - **`None`** is passed as input, meaning no new message is added; the graph continues with the current state.
  - **`thread`** specifies the conversation context.
  - **`stream_mode="values"`** indicates that the stream returns a dictionary of values representing the state changes.

- **`event['messages'][-1].pretty_print()`**  
  Prints the last message from the current event:
  - Initially, it will display our updated human message: `"No, actually multiply 3 and 3!"`.
  - Then, after processing, it shows the AI's response—typically including tool calls (e.g., to perform multiplication) and their results.

---

# 🔄 Continuing After a Breakpoint

The graph execution is designed to **pause at breakpoints** (in this case, before the assistant node). After reviewing or modifying the state, you can call `graph.stream` again to continue:

```python
for event in graph.stream(None, thread, stream_mode="values"):
    event['messages'][-1].pretty_print()
```

This resumes the graph, allowing the AI to process the updated conversation and perform any remaining actions (e.g., executing a tool call to multiply 3 by 3).

---

# 🌟 Key Takeaways

- **Dynamic Updates**:  
  You can update the graph state in real time, allowing corrections or refinements before the AI continues processing.

- **Add vs. Overwrite**:  
  - **Appending**: If you provide a new message without an ID, it is added to the list.
  - **Overwriting**: If you specify a message with an ID, the reducer will replace the existing message with that ID.

- **Real-World Utility**:  
  This mechanism is especially useful in systems where human oversight is critical—such as customer service chatbots, automated decision systems, or debugging AI workflows.

- **Step-by-Step Execution**:  
  The graph execution can be paused, inspected, and resumed, which makes it easier to understand the AI’s behavior and to intervene when necessary.

By understanding and applying these concepts, you can build AI systems that are not only powerful but also flexible and interactive, capable of integrating human corrections seamlessly.

Would you like further examples or more details on any of the steps?

---

# 🖥️ **Editing Graph State with LangGraph API: A Beginner's Guide**  

LangGraph is a framework that allows us to interact with and modify graph states dynamically. This is particularly useful in AI agents, chatbots, or workflow automation. Let's explore how to edit a graph state with the LangGraph API using Python.

---

## 🚀 **What is LangGraph API?**  
LangGraph is an API that enables us to create, modify, and interact with AI-powered agents using a graph-based execution flow. It is useful for:  
✅ Modifying the state of an ongoing process.  
✅ Injecting breakpoints into an execution flow.  
✅ Debugging AI workflows by modifying messages or outputs dynamically.  

### 🎯 **Real-World Use Cases**  
- **Chatbots & Virtual Assistants:** Modify conversations dynamically without restarting the chatbot session.  
- **AI-Powered Workflows:** Adjust an agent's task execution at runtime.  
- **Automated Customer Support:** Modify queries or responses based on real-time user interactions.  

---

## 🔧 **Setting Up the LangGraph API**  

### 📌 **1. Checking Compatibility**
Before using LangGraph, we ensure that it is not running in Google Colab and is supported on macOS:

```python
import platform

if 'google.colab' in str(get_ipython()) or platform.system() != 'Darwin':
    raise Exception("Unfortunately, LangGraph Studio is not supported on Google Colab or requires a Mac")
```

🔹 **Explanation:**  
- We check if the platform is **Google Colab** or **not macOS** using `platform.system()`.  
- If either condition is met, we raise an exception.  

---

### 📌 **2. Connecting to LangGraph API**
Next, we establish a connection to the LangGraph client:

```python
from langgraph_sdk import get_client

client = get_client(url="http://localhost:56091")  # Connect to the local LangGraph instance
```

🔹 **Explanation:**  
- We import `get_client` from `langgraph_sdk`.  
- We create a client object and pass the **URL of the local LangGraph deployment**.  

---

## 🛠️ **Creating and Managing Threads in LangGraph**  

### 📌 **3. Creating a Thread for Communication**
To interact with our agent, we need to create a **thread**:

```python
initial_input = {"messages": "Multiply 2 and 3"}

thread = await client.threads.create()  # Create a new thread for conversation
```

🔹 **Explanation:**  
- `initial_input` contains the first message to be processed: `"Multiply 2 and 3"`.  
- `client.threads.create()` creates a **new thread** that stores conversation state.  

---

### 📌 **4. Streaming Responses and Handling Breakpoints**  
We now stream the responses from the agent with an **interrupt point** before the `"assistant"` step.

```python
async for chunk in client.runs.stream(
    thread["thread_id"],
    "agent",
    input=initial_input,
    stream_mode="values",
    interrupt_before=["assistant"],  # Break before AI responds
):
    print(f"Receiving new event of type: {chunk.event}...")
    messages = chunk.data.get('messages', [])
    if messages:
        print(messages[-1])  # Print the latest message
    print("-" * 50)
```

🔹 **Explanation:**  
- We use `client.runs.stream()` to **stream responses** from the agent.  
- `"interrupt_before": ["assistant"]` **pauses execution** before the assistant responds.  
- We iterate over the stream and print new messages as they arrive.  

---

## 📊 **Fetching the Current State of the Conversation**  
We can retrieve the current conversation state to inspect its data:

```python
current_state = await client.threads.get_state(thread['thread_id'])
print(current_state)
```

🔹 **Explanation:**  
- `client.threads.get_state(thread["thread_id"])` **fetches the current state** of the conversation.  

### 📝 **Example Output:**
```json
{
  "values": {
    "messages": [
      {"content": "Multiply 2 and 3", "type": "human", "id": "882dabe4"}
    ]
  },
  "next": ["assistant"],
  "tasks": [{"id": "a71c0b80", "name": "assistant"}]
}
```

---

## ✍️ **Editing Messages in the Graph State**  
We can **modify** the last message in the state:

```python
last_message = current_state['values']['messages'][-1]
last_message['content'] = "No, actually multiply 3 and 3!"
```

🔹 **Explanation:**  
- `current_state['values']['messages'][-1]` retrieves the **last message**.  
- We update its `content` to **change the instruction**.  

### 📝 **Modified Message:**
```json
{
  "content": "No, actually multiply 3 and 3!",
  "type": "human",
  "id": "882dabe4"
}
```

---

## 🔄 **Updating the Graph State with the Modified Message**  
After modifying the message, we update the state:

```python
await client.threads.update_state(thread['thread_id'], {"messages": last_message})
```

🔹 **Explanation:**  
- `client.threads.update_state()` updates the **conversation state** with the edited message.  

---

## ▶️ **Resuming the Execution After Modification**  
After updating the message, we resume the execution:

```python
async for chunk in client.runs.stream(
    thread["thread_id"],
    assistant_id="agent",
    input=None,  # No new input, just continue execution
    stream_mode="values",
    interrupt_before=["assistant"],
):
    print(f"Receiving new event of type: {chunk.event}...")
    messages = chunk.data.get('messages', [])
    if messages:
        print(messages[-1])
    print("-" * 50)
```

🔹 **Explanation:**  
- We resume the execution **without any new input** (`input=None`).  
- The AI assistant now processes the **modified instruction**.  

---

## 🎯 **Final Output After Modification**
The assistant correctly processes the new instruction:

```json
{
  "content": "No, actually multiply 3 and 3!",
  "type": "human"
}
{
  "content": "9",
  "type": "tool",
  "name": "multiply"
}
```

💡 **The AI correctly computed `3 × 3 = 9` instead of `2 × 3 = 6`.**  

---

## 🎯 **Key Takeaways**
✅ **LangGraph API** allows **modifying live AI conversations** dynamically.  
✅ **Breakpoints** let us pause execution before an AI agent responds.  
✅ We can **fetch, edit, and update conversation states** in real time.  
✅ **Useful for debugging, workflow automation, and AI-powered applications.**  

Would you like me to expand on a particular section? 🚀


---

# 🌟 **Understanding State Management with Human Feedback in an AI Agent**  

## 🔍 **Introduction**  
In this explanation, we will break down the given code and concept into easy-to-understand parts. We will explain **state management**, **streaming events**, **human feedback integration**, and how an **AI agent** processes arithmetic tool calls while allowing manual user intervention.

We will use **real-world examples**, detailed **code breakdowns**, and a **step-by-step explanation** to make it beginner-friendly.

---

## 🏗️ **What is State Management in AI Agents?**  

State management is a process that allows an AI system to remember and modify its current state based on external inputs (such as human feedback). This is essential for building **interactive AI agents** that can process and refine their responses over time.  

### **🔹 Real-World Example: AI Chatbots**
Consider a chatbot handling customer support requests. A user may ask:  
**"Cancel my order."**  

The AI processes this and responds:  
**"Which order would you like to cancel?"**  

If the AI cannot fetch order details correctly, the user can **manually intervene** and correct the input. The system updates the state and continues processing with new user feedback.

---

## 🚀 **Breaking Down the Code**  

We will explain each section of the code with **examples** and **detailed explanations**.

---

### 🛠️ **Streaming AI Events and Processing Messages**
The following code listens for AI events and processes tool responses:

```python
async for chunk in client.runs.stream(
    thread["thread_id"],
    assistant_id="agent",
    input=None,
    stream_mode="values",
    interrupt_before=["assistant"],
):
    print(f"Receiving new event of type: {chunk.event}...")
    messages = chunk.data.get('messages', [])
    if messages:
        print(messages[-1])
    print("-" * 50)
```

### 🔍 **Breaking It Down**
1. **`async for chunk in client.runs.stream(...)`**  
   - Streams real-time events from an AI assistant in an asynchronous manner.
   - Each event represents a **response** or **tool output**.

2. **`thread["thread_id"]`**  
   - Represents the unique identifier for an AI conversation.

3. **`assistant_id="agent"`**  
   - Refers to the AI assistant handling the interaction.

4. **`interrupt_before=["assistant"]`**  
   - Tells the system to pause execution before the assistant node runs.  
   - This allows manual intervention (human feedback) before continuing execution.

5. **`print(messages[-1])`**  
   - Retrieves and prints the latest message received from the AI system.

---

### 🛠️ **Defining AI Nodes for Human Feedback**
To allow human intervention in the AI process, we define nodes:

```python
# System message
sys_msg = SystemMessage(content="You are a helpful assistant tasked with performing arithmetic on a set of inputs.")

# No-op node that should be interrupted on
def human_feedback(state: MessagesState):
    pass

# Assistant node
def assistant(state: MessagesState):
   return {"messages": [llm_with_tools.invoke([sys_msg] + state["messages"])]}
```

### 🔍 **Breaking It Down**
1. **`sys_msg = SystemMessage(...)`**  
   - Defines a **system message** instructing the assistant to perform arithmetic.

2. **`def human_feedback(state: MessagesState): pass`**  
   - Represents a placeholder node where human feedback can be inserted.
   - The AI system **pauses here** for user input.

3. **`def assistant(state: MessagesState):`**  
   - Calls an AI model (`llm_with_tools.invoke(...)`) to process input messages.
   - Uses previous state messages along with system instructions.

---

### 🛠️ **Building the AI Processing Graph**
A **state graph** connects different processing steps.

```python
# Graph
builder = StateGraph(MessagesState)

# Define nodes
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))
builder.add_node("human_feedback", human_feedback)

# Define edges (control flow)
builder.add_edge(START, "human_feedback")
builder.add_edge("human_feedback", "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition,  # Routes to tools if a tool call is detected
)
builder.add_edge("tools", "human_feedback")

# Memory for saving state
memory = MemorySaver()
graph = builder.compile(interrupt_before=["human_feedback"], checkpointer=memory)
```

### 🔍 **Breaking It Down**
1. **`StateGraph(MessagesState)`**  
   - Creates a **state graph** to define AI execution flow.

2. **Adding Nodes:**  
   - `"assistant"` → AI assistant processes queries.  
   - `"tools"` → Handles external tool execution (like a multiplication tool).  
   - `"human_feedback"` → Placeholder for user intervention.

3. **Defining Edges (Control Flow):**  
   - AI execution starts at `"human_feedback"`.  
   - If user feedback is provided, it moves to `"assistant"`.  
   - AI decides whether to call a tool or return a final response.

4. **`memory = MemorySaver()`**  
   - Saves the conversation state for future use.

5. **`interrupt_before=["human_feedback"]`**  
   - Ensures human intervention is requested before final AI execution.

---

### 🛠️ **Executing AI with Human Feedback**
The AI processes user inputs, allowing manual correction.

```python
# Input
initial_input = {"messages": "Multiply 2 and 3"}

# Thread
thread = {"configurable": {"thread_id": "5"}}

# Run the graph until the first interruption
for event in graph.stream(initial_input, thread, stream_mode="values"):
    event["messages"][-1].pretty_print()

# Get user input
user_input = input("Tell me how you want to update the state: ")

# Update state based on human feedback
graph.update_state(thread, {"messages": user_input}, as_node="human_feedback")

# Continue execution
for event in graph.stream(None, thread, stream_mode="values"):
    event["messages"][-1].pretty_print()
```

### 🔍 **Breaking It Down**
1. **`initial_input = {"messages": "Multiply 2 and 3"}`**  
   - User asks AI to perform multiplication.

2. **`graph.stream(...)`**  
   - Starts processing the AI graph **until human intervention is needed**.

3. **`user_input = input("Tell me how you want to update the state: ")`**  
   - User manually **corrects** or **modifies** the AI's response.

4. **`graph.update_state(...)`**  
   - Updates the AI system with **new user feedback**.

5. **`graph.stream(None, thread, stream_mode="values")`**  
   - Resumes execution with the updated state.

---

## 🎯 **Final Output Example**
### **Scenario 1: Correct AI Response**
```
================================ Human Message =================================
Multiply 2 and 3
================================== Ai Message ==================================
Tool Calls:
  multiply (call_xxx)
  Args:
    a: 2
    b: 3
================================= Tool Message =================================
Name: multiply

6
================================== Ai Message ==================================
The result of multiplying 2 and 3 is 6.
```

### **Scenario 2: Human Correction**
```
Tell me how you want to update the state: no, multiply 3 and 3
================================ Human Message =================================
Multiply 3 and 3
================================= Tool Message =================================
Name: multiply

9
================================== Ai Message ==================================
The result of multiplying 3 and 3 is 9.
```

---

## 📌 **Conclusion**
✅ **Key Takeaways:**  
- **State Management** helps AI systems handle **dynamic** user interactions.  
- **Interrupting AI Execution** allows for **human intervention** when needed.  
- **State Graphs** define the **flow of AI decisions**.  
- **Real-World Application:** Used in **chatbots, customer support, and AI-driven decision-making systems**.

🔹 **By using this approach, AI agents can provide more accurate and user-refined responses.** 🚀