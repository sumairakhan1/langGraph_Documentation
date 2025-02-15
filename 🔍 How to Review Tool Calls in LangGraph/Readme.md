# 🔍 **How to Review Tool Calls in LangGraph**  

In this guide, we will deeply explore **reviewing tool calls** in **LangGraph**, explaining every aspect step by step. This guide is designed for **beginners**, providing **real-world use cases, detailed explanations, and code examples with line-by-line breakdowns**.

---

## 🛠 **Prerequisites**  
Before proceeding, you should have a basic understanding of the following:  

✅ **Tool calling** – How to make calls to external tools/functions.  
✅ **Human-in-the-loop (HIL)** – When humans intervene in automated processes.  
✅ **LangGraph Glossary** – Understanding the basic terms in LangGraph.  

---

## 🤖 **What Are Tool Calls?**  

In **LangGraph**, **tool calls** allow agents to perform actions such as:  

- Executing SQL queries.  
- Generating summaries and storing them in a **graph state**.  
- Calling APIs or external services.  

These tool calls may require human intervention to ensure accuracy before execution.

---

## 👤 **Why Human-in-the-loop (HIL) Is Important?**  

HIL is useful when:  

🔹 **Reviewing** tool-generated responses.  
🔹 **Approving or modifying** tool-generated content.  
🔹 **Providing feedback** to refine the AI's understanding.  

For example, in an **AI-powered financial assistant**, before executing a transaction, we may want a human to verify the payment details.

---

## ⚡ **Types of Human-in-the-loop Interactions**  

There are three common ways to review tool calls:  

1️⃣ **Approve and continue** ✅  
2️⃣ **Modify manually and then continue** ✍️  
3️⃣ **Provide natural language feedback to adjust the response** 💬  

---

## 🏗 **Implementing HIL in LangGraph**  

### 🔹 **Using the `interrupt()` Function**  

The `interrupt()` function **pauses execution** to get input from a human reviewer before continuing.  

### **🚀 Code Example: Implementing Human Review in LangGraph**  

```python
from typing import Literal
from langgraph.predefined import interrupt
from langgraph.graph import Command

def human_review_node(state) -> Command[Literal["call_llm", "run_tool"]]:
    """
    This function pauses execution and asks for human input 
    before continuing with tool execution.
    """

    # Ask the human reviewer whether the tool call is correct
    human_review = interrupt(
        {
            "question": "Is this correct?",
            "tool_call": tool_call  # Display the tool call for review
        }
    )

    # Get the human review action and data
    review_action, review_data = human_review

    # Case 1: If the reviewer approves, proceed with tool execution
    if review_action == "continue":
        return Command(goto="run_tool")

    # Case 2: If the reviewer wants to update the tool call
    elif review_action == "update":
        updated_msg = get_updated_msg(review_data)
        return Command(goto="run_tool", update={"messages": [updated_msg]})

    # Case 3: If the reviewer gives feedback, update the agent’s knowledge
    elif review_action == "feedback":
        feedback_msg = get_feedback_msg(review_data)
        return Command(goto="call_llm", update={"messages": [feedback_msg]})
```

---

## 📌 **Breaking Down the Code**  

### **🔹 `interrupt()` Function**  
- **Pauses execution** to get human input.  
- **Displays the tool call** for review.  

### **🔹 `review_action` Handling**  
- If the reviewer **approves** (`"continue"`), the execution **proceeds** to `"run_tool"`.  
- If the reviewer **modifies** (`"update"`), the tool call is **updated** before execution.  
- If the reviewer **provides feedback** (`"feedback"`), the **agent's response is improved** before calling the tool again.  

---

## ⚙ **Setting Up the Environment**  

### 1️⃣ **Install Required Packages**  

Run the following command to install the necessary packages:  

```python
%%capture --no-stderr
%pip install --quiet -U langgraph langchain_anthropic
```

This installs:  
- **LangGraph** → For graph-based AI workflows.  
- **LangChain Anthropic** → For working with Anthropic’s Claude LLM.  

---

### 2️⃣ **Set API Keys for Anthropic**  

Since we are using **Anthropic LLM**, we need to **set API keys** for authentication.  

```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("ANTHROPIC_API_KEY")
```

💡 **Explanation:**  
- This function **checks if the API key is already set**.  
- If **not set**, it **prompts the user** to enter the key.  

---

## 🌍 **Real-World Use Case**  

🔹 **AI-Based Customer Support** 📞  

Imagine a chatbot that automatically generates **customer support replies**.  

**Before sending the reply**, a human agent can:  
✅ **Approve the response** if correct.  
✏ **Edit the response** for accuracy.  
💬 **Provide feedback** to refine the chatbot’s future responses.  

This ensures high-quality customer interactions.

---

## 🏁 **Conclusion**  

✅ **Tool calls** allow agents to execute actions like SQL queries and summaries.  
✅ **Human-in-the-loop (HIL)** ensures accuracy by allowing human reviewers to approve, modify, or provide feedback.  
✅ **LangGraph's `interrupt()` function** helps pause execution and collect human input.  
✅ **We can implement this in LangGraph** to create safe and reliable AI-powered applications.  

---

Do you need further explanation or another example? 😊

---

# 🚀 **Understanding and Implementing Human-in-the-Loop (HIL) in Tool Calls using LangGraph**

## 🧠 **Introduction**
In AI-driven applications, **Human-in-the-Loop (HIL)** is a critical concept where human intervention is needed to validate, modify, or provide feedback before an automated process proceeds. This is particularly useful in **agentic systems**, where AI models interact with external tools, APIs, or databases.

### 🔍 **Real-World Applications of Human-in-the-Loop**
HIL is commonly used in:
1. **AI-powered chatbots** – A customer support chatbot allows human agents to review AI responses before sending them.
2. **Automated Data Processing** – A system that processes medical records may require human approval before updating sensitive data.
3. **Search Engines & Summarization Tools** – AI-generated summaries may need human verification to ensure accuracy.
4. **Fraud Detection** – AI flags suspicious transactions, but a human reviews and confirms them before taking action.

---
## 🔗 **Prerequisites**
Before proceeding, ensure you understand:
✅ **Tool Calling** – The AI interacts with external tools/functions.  
✅ **LangGraph Basics** – A framework for managing AI workflows with state management.  
✅ **Interrupt Handling** – Stopping execution for user input before continuing.  

---
## 🏗 **How HIL Works in Tool Calls**
### **1️⃣ Workflow Overview**
1. The AI model suggests an action.
2. A **human review node** interrupts execution for validation.
3. The human can:
   - ✅ **Approve** the AI’s suggestion.
   - ✏️ **Modify** the tool call and continue.
   - 💬 **Provide feedback** for improvement.
4. Execution resumes based on human input.

---
## 📌 **Step-by-Step Implementation**
### 📦 **1. Install Required Packages**
First, install the necessary dependencies:

```python
%%capture --no-stderr
%pip install --quiet -U langgraph langchain_anthropic
```

### 🔑 **2. Set Up API Keys**
We need to set an **Anthropic API key** to use the AI model:

```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("ANTHROPIC_API_KEY")  # Prompt user for API key
```

---
## 🛠 **Building the Human-in-the-Loop System**
### 🏗 **3. Define the Tool**
Here, we define a tool that fetches the weather based on a city name.

```python
from langchain_core.tools import tool

@tool
def weather_search(city: str):
    """Search for the weather"""
    print("----")
    print(f"Searching for: {city}")  # Simulate a search
    print("----")
    return "Sunny!"  # Example static response
```
🔹 **Explanation:**  
- This function is a **tool** that accepts a `city` as input and returns a **mock weather result**.
- In a real-world scenario, this could call a weather API (e.g., OpenWeatherMap).

---
### 🤖 **4. Initialize AI Model**
We use **ChatAnthropic** and bind the weather tool.

```python
from langchain_anthropic import ChatAnthropic

model = ChatAnthropic(model_name="claude-3-5-sonnet-latest").bind_tools(
    [weather_search]
)
```
🔹 **Explanation:**  
- We create an instance of `ChatAnthropic` (a Claude model).
- The `.bind_tools([weather_search])` links the AI model with our weather tool.

---
### 🔄 **5. Define AI Decision Making**
The AI suggests an action.

```python
def call_llm(state):
    return {"messages": [model.invoke(state["messages"])]}
```
🔹 **Explanation:**  
- This function **calls the AI model** to decide the next step.
- `state["messages"]` contains previous interactions, ensuring continuity.

---
### 👤 **6. Implement Human Review Node**
Here’s where human validation occurs.

```python
from langgraph.types import Command, interrupt

def human_review_node(state) -> Command[Literal["call_llm", "run_tool"]]:
    last_message = state["messages"][-1]
    tool_call = last_message.tool_calls[-1]

    # Interrupt execution for human input
    human_review = interrupt(
        {
            "question": "Is this correct?",
            "tool_call": tool_call,
        }
    )

    review_action = human_review["action"]
    review_data = human_review.get("data")

    # Approve the tool call
    if review_action == "continue":
        return Command(goto="run_tool")

    # Modify tool call and continue
    elif review_action == "update":
        updated_message = {
            "role": "ai",
            "content": last_message.content,
            "tool_calls": [
                {
                    "id": tool_call["id"],
                    "name": tool_call["name"],
                    "args": review_data,  # Updated by human
                }
            ],
            "id": last_message.id,
        }
        return Command(goto="run_tool", update={"messages": [updated_message]})

    # Provide feedback to LLM
    elif review_action == "feedback":
        tool_message = {
            "role": "tool",
            "content": review_data,
            "name": tool_call["name"],
            "tool_call_id": tool_call["id"],
        }
        return Command(goto="call_llm", update={"messages": [tool_message]})
```
🔹 **Explanation:**  
- **Interrupts execution** to allow a human review.
- The human can:
  - **Approve** (`"continue"`) → Proceeds to run the tool.
  - **Modify** (`"update"`) → Changes tool call parameters.
  - **Give feedback** (`"feedback"`) → AI improves for the next attempt.

---
### 🔄 **7. Run the Tool**
If approved, the tool executes.

```python
def run_tool(state):
    new_messages = []
    tools = {"weather_search": weather_search}
    tool_calls = state["messages"][-1].tool_calls

    for tool_call in tool_calls:
        tool = tools[tool_call["name"]]
        result = tool.invoke(tool_call["args"])
        new_messages.append(
            {
                "role": "tool",
                "name": tool_call["name"],
                "content": result,
                "tool_call_id": tool_call["id"],
            }
        )
    return {"messages": new_messages}
```
🔹 **Explanation:**  
- Fetches the tool based on the tool name.
- **Executes the tool function** and stores the result in `new_messages`.

---
### 🔀 **8. Define Routing Logic**
This decides the next step.

```python
def route_after_llm(state) -> Literal["human_review_node", "END"]:
    if len(state["messages"][-1].tool_calls) == 0:
        return "END"
    else:
        return "human_review_node"
```
🔹 **Explanation:**  
- If there’s a **tool call**, send it for **human review**.
- Otherwise, end the workflow.

---
### 🔧 **9. Build the Graph**
Finally, we structure everything using **StateGraph**.

```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver
from IPython.display import Image, display

builder = StateGraph(State)
builder.add_node(call_llm)
builder.add_node(run_tool)
builder.add_node(human_review_node)
builder.add_edge(START, "call_llm")
builder.add_conditional_edges("call_llm", route_after_llm)
builder.add_edge("run_tool", "call_llm")

memory = MemorySaver()
graph = builder.compile(checkpointer=memory)

# Visualize the graph
display(Image(graph.get_graph().draw_mermaid_png()))
```
🔹 **Explanation:**  
- Defines the **workflow** using `StateGraph`.
- Adds **nodes** (AI, review, tool execution).
- **Connects** them logically.
- Uses **memory** to track execution history.

---
## 🎯 **Conclusion**
✅ We implemented a **Human-in-the-Loop** AI system with LangGraph.  
✅ The system **interrupts execution**, allowing human validation.  
✅ Humans can **approve, modify, or provide feedback**.  
✅ The workflow is **automated but supervised** for better accuracy.

This approach ensures **AI reliability** and **human oversight**, making it ideal for applications requiring **trustworthy AI decisions**! 🚀

---


# 🌟 **Example with No Review & Approving Tool in LangGraph**

In this guide, we'll explore two scenarios in LangGraph: one where **no human review is required** because no tools are called, and another where a **tool call is approved** by a human. This is especially useful for understanding how automated workflows can switch between fully automated and human-supervised processes.

---

## 🚀 **Scenario 1: Example with No Review**

When no external tools are called by the AI, the workflow completes without human intervention.

### 🔍 **Real-World Example**  
Imagine a **chatbot greeting system**: A user says "hi!" and the bot replies with a greeting. Since no additional actions (like checking weather or processing data) are required, the system doesn't pause for human review.

### 💻 **Code Example: No Review Needed**

```python
# Input: Initial conversation with a simple greeting.
initial_input = {"messages": [{"role": "user", "content": "hi!"}]}

# Thread: Each conversation is identified by a unique thread_id.
thread = {"configurable": {"thread_id": "1"}}

# Run the graph until the first interruption (if any).
for event in graph.stream(initial_input, thread, stream_mode="updates"):
    print(event)
    print("\n")
```

### 📖 **Line-by-Line Explanation**

- **Line 1-2:**  
  ```python
  # Input: Initial conversation with a simple greeting.
  initial_input = {"messages": [{"role": "user", "content": "hi!"}]}
  ```  
  - We define the initial state as a message from the user saying `"hi!"`.

- **Line 4-5:**  
  ```python
  # Thread: Each conversation is identified by a unique thread_id.
  thread = {"configurable": {"thread_id": "1"}}
  ```  
  - This creates a unique **thread identifier** for the conversation. Think of it as a session ID.

- **Line 7-9:**  
  ```python
  # Run the graph until the first interruption (if any).
  for event in graph.stream(initial_input, thread, stream_mode="updates"):
      print(event)
      print("\n")
  ```  
  - We stream the graph's execution. Since the AI does not call any external tool (like a weather search), the execution completes without triggering a human review interruption.

- **Expected Output:**  
  The output will display a response from the AI (an `AIMessage`), and the state shows that no further actions (or reviews) are pending. The conversation completes automatically.

---

## ✅ **Scenario 2: Example of Approving a Tool**

When a tool is called (e.g., checking the weather), the system **pauses for human review** before executing the tool. The human can then **approve** the action, which resumes execution.

### 🔍 **Real-World Example**  
Imagine an **AI travel assistant** that checks the weather for your destination. Before the assistant fetches the weather data, it pauses and asks, "Is this correct?" A travel agent (or the user) can then review and approve the query to ensure that the correct location is being checked.

### 💻 **Code Example: Approving the Tool Call**

#### **Step 1: Initial Request & Graph Execution**

```python
# Input: User asks about the weather in San Francisco.
initial_input = {"messages": [{"role": "user", "content": "what's the weather in sf?"}]}

# Thread: Unique identifier for this conversation.
thread = {"configurable": {"thread_id": "2"}}

# Run the graph until the first interruption (human review step).
for event in graph.stream(initial_input, thread, stream_mode="updates"):
    print(event)
    print("\n")
```

### 📖 **Line-by-Line Explanation**

- **Line 1-2:**  
  ```python
  # Input: User asks about the weather in San Francisco.
  initial_input = {"messages": [{"role": "user", "content": "what's the weather in sf?"}]}
  ```  
  - The user inputs a request for the weather in San Francisco.

- **Line 4-5:**  
  ```python
  # Thread: Unique identifier for this conversation.
  thread = {"configurable": {"thread_id": "2"}}
  ```  
  - We assign a new thread ID for this conversation to keep its state separate.

- **Line 7-9:**  
  ```python
  # Run the graph until the first interruption (human review step).
  for event in graph.stream(initial_input, thread, stream_mode="updates"):
      print(event)
      print("\n")
  ```  
  - The graph runs, and the AI processes the request. It then calls the `weather_search` tool (as indicated by the `tool_call` in the output) and pauses for human review.

- **Intermediate Output:**  
  The printed output shows two key things:
  1. A message from the LLM that includes a tool call (requesting a weather search).
  2. An interrupt event that shows the system is waiting for human review:
     ```python
     {'__interrupt__': (Interrupt(value={'question': 'Is this correct?', 'tool_call': {...}}, resumable=True, ...),)}
     ```

- **Checking Pending Execution:**  
  ```python
  print("Pending Executions!")
  print(graph.get_state(thread).next)
  ```  
  - This confirms that the graph is waiting on the `human_review_node`.

#### **Step 2: Approve the Tool Call**

To continue, we need to signal that the human approves the tool call by sending a resume command with `{"action": "continue"}`.

```python
from langgraph.types import Command

# Resume execution by approving the tool call (no changes needed).
for event in graph.stream(
    Command(resume={"action": "continue"}),
    thread,
    stream_mode="updates",
):
    print(event)
    print("\n")
```

### 📖 **Line-by-Line Explanation**

- **Line 1:**  
  ```python
  from langgraph.types import Command
  ```  
  - We import the `Command` type used to resume the workflow.

- **Line 3-7:**  
  ```python
  # Resume execution by approving the tool call (no changes needed).
  for event in graph.stream(
      Command(resume={"action": "continue"}),
      thread,
      stream_mode="updates",
  ):
      print(event)
      print("\n")
  ```  
  - We resume the graph by providing a command with `resume={"action": "continue"}`.  
  - This tells the system that the human approves the tool call without any modifications.
  - The graph then proceeds to execute the tool.

- **Expected Subsequent Output:**
  1. A confirmation from the `human_review_node` (e.g., `{'human_review_node': None}`).
  2. The tool execution output:
     ```python
     ----
     Searching for: sf
     ----
     {'run_tool': {'messages': [{'role': 'tool', 'name': 'weather_search', 'content': 'Sunny!', ...}]}}
     ```
  3. A follow-up message from the LLM that interprets the tool's result:
     ```python
     {'call_llm': {'messages': [AIMessage(content="According to the search, it's sunny in San Francisco today!", ...)]}}
     ```

---

## 🎯 **Key Takeaways**

- **No Review Scenario:**  
  When the AI response does not trigger any tool calls, the process completes automatically without any human intervention.

- **Tool Approval Scenario:**  
  When a tool is called (e.g., checking weather), the system **pauses for human review**. The human can then **approve** the call, allowing the tool to execute and the process to continue.

- **Real-World Application:**  
  These patterns are especially useful in scenarios like customer support, travel planning, or financial applications where:
  - **Accuracy** is critical.
  - **Human oversight** ensures that automated processes execute correctly.
  - **Tool calls** are verified before executing actions that might have significant consequences.

This structured approach helps build **robust, reliable systems** that combine the power of AI with human judgment, ensuring better outcomes in real-world applications.


---

# 🔧 **Editing and Providing Feedback for Tool Calls in LangGraph**

In this guide, we'll explore two important scenarios when working with tool calls in LangGraph:

1. **Editing a Tool Call** – Changing the parameters (or even the tool) before executing it.  
2. **Giving Feedback to a Tool Call** – Instead of manually editing, providing natural language feedback that the AI uses to adjust the call.

These concepts allow **human-in-the-loop** (HIL) interventions to ensure that automated processes perform accurately and as intended.

---

## 🌍 **Real-World Use Cases**

- **Travel Assistant:**  
  Imagine an AI travel assistant that searches for weather information. A user might initially ask, "What's the weather in sf?"  
  - **Editing a Tool Call:** The agent might automatically interpret "sf" as "San Francisco" but sometimes the user may want a more specific query like "San Francisco, USA" to avoid ambiguity.  
  - **Giving Feedback:** Alternatively, the user might indicate that the query should include both city and country information (e.g., "User requested changes: use <city, country> format for location").

- **Customer Support Chatbot:**  
  A support bot could use a tool to fetch order details. Before executing, a supervisor might modify the order number format or provide feedback if the input is ambiguous.

---

# 🔧 **Scenario 1: Editing a Tool Call**

When a tool call needs modifications (e.g., updating parameters), we can use the **`Command(resume={"action": "update", "data": ...})`** option. This takes the existing tool call, applies the changes provided by the user, and then executes the updated call.

### 💻 **Code Example: Editing a Tool Call**

```python
# --- Step 1: Define Input and Thread ---
# The user initially asks: "what's the weather in sf?"
initial_input = {"messages": [{"role": "user", "content": "what's the weather in sf?"}]}

# Each conversation has a unique thread id; here thread_id is "3"
thread = {"configurable": {"thread_id": "3"}}

# --- Step 2: Run the Graph Until the First Interruption ---
# This runs the workflow and stops at the human review stage.
for event in graph.stream(initial_input, thread, stream_mode="updates"):
    print(event)
    print("\n")
```

> **Explanation:**  
> - **Initial Input:** We simulate a user request about the weather in San Francisco by using `"sf"` as the parameter.
> - **Thread Setup:** A unique thread ID (`"3"`) is used to manage the state of this conversation.
> - **Graph Streaming:** The graph processes the input until it reaches an interruption point where human review is needed (because the AI has generated a tool call).

After running the above, the system prints an interrupt message that looks like this:

```python
{'__interrupt__': (Interrupt(value={'question': 'Is this correct?', 'tool_call': {'name': 'weather_search', 'args': {'city': 'sf'}, ... }}, ...),)}
```

This indicates the system is **waiting for human input** on the tool call.

---

### 🔄 **Step 3: Editing the Tool Call**

Now, we want to update the tool call so that instead of searching for `"sf"`, it uses `"San Francisco, USA"`.

```python
from langgraph.types import Command  # Import Command to resume execution

# Resume the graph with the update action:
for event in graph.stream(
    Command(resume={"action": "update", "data": {"city": "San Francisco, USA"}}),
    thread,
    stream_mode="updates",
):
    print(event)
    print("\n")
```

> **Line-by-Line Explanation:**
> - **Importing Command:**  
>   ```python
>   from langgraph.types import Command
>   ```  
>   This allows us to send a resume command to the graph.
>
> - **Resuming with Update:**  
>   ```python
>   Command(resume={"action": "update", "data": {"city": "San Francisco, USA"}})
>   ```  
>   Here, we send a resume command with:
>   - `"action": "update"` to indicate we're editing the tool call.
>   - `"data": {"city": "San Francisco, USA"}` provides the new parameter for the tool.
>
> - **Graph Streaming:**  
>   The loop resumes the graph execution. The human review node updates the AI message by replacing the old argument (`"sf"`) with the new one (`"San Francisco, USA"`), and then the tool is executed.
>
> - **Output:**  
>   The updated tool call message is printed, then the tool executes, displaying:
>   ```
>   ----
>   Searching for: San Francisco, USA
>   ----
>   ```
>   Finally, the AI confirms, for example, "According to the search, it's sunny in San Francisco right now!"

---

# 💬 **Scenario 2: Giving Feedback to a Tool Call**

Instead of directly updating parameters, sometimes you want to provide **natural language feedback**. This feedback is then processed by the AI to adjust the tool call.

### 💻 **Code Example: Providing Feedback**

#### **Step 1: Initial Request and Interruption**

```python
# --- Step 1: Define Input and Thread ---
initial_input = {"messages": [{"role": "user", "content": "what's the weather in sf?"}]}
thread = {"configurable": {"thread_id": "4"}}

# Run the graph until it pauses for human review
for event in graph.stream(initial_input, thread, stream_mode="updates"):
    print(event)
    print("\n")
```

> **Explanation:**
> - We simulate the same user request.
> - A unique thread ID `"4"` is assigned.
> - The graph processes the input and stops at the human review stage, printing an interrupt message.

#### **Step 2: Providing Feedback**

Now, instead of editing the tool call directly, we provide feedback using the resume action `"feedback"`.

```python
from langgraph.types import Command  # Ensure Command is imported

# Provide natural language feedback as resume data:
for event in graph.stream(
    Command(
        resume={
            "action": "feedback",
            "data": "User requested changes: use <city, country> format for location"
        }
    ),
    thread,
    stream_mode="updates",
):
    print(event)
    print("\n")
```

> **Line-by-Line Explanation:**
> - **Importing Command:**  
>   Ensures we can create a resume command.
>
> - **Resume with Feedback:**  
>   ```python
>   Command(
>       resume={
>           "action": "feedback",
>           "data": "User requested changes: use <city, country> format for location"
>       }
>   )
>   ```  
>   Here, `"action": "feedback"` indicates we are not editing the tool call directly but instead giving feedback.  
>   The `"data"` field contains the natural language feedback.
>
> - **Graph Streaming:**  
>   The graph takes the feedback and creates a new tool message that incorporates this feedback. It then routes the conversation back to the AI (the `call_llm` node), which may generate a new tool call based on the feedback.
>
> - **Output:**  
>   The system prints the updated messages showing a tool message with the feedback content. The AI then attempts to improve its tool call accordingly (e.g., updating the parameter to `"San Francisco, USA"`).

#### **Step 3: Approving the New Tool Call**

After the AI processes the feedback, it may generate a new tool call. You can then approve this new call to resume execution:

```python
for event in graph.stream(
    Command(resume={"action": "continue"}),
    thread,
    stream_mode="updates"
):
    print(event)
    print("\n")
```

> **Explanation:**
> - **Resuming with Continue:**  
>   By using `"action": "continue"`, you signal that the new tool call is approved.
>
> - **Graph Execution:**  
>   The graph then executes the updated tool call. For example, it prints:
>   ```
>   ----
>   Searching for: San Francisco, USA
>   ----
>   ```
>   Finally, the AI responds with a message like "The weather in San Francisco is sunny!"

---

# 🎯 **Key Takeaways**

- **Editing a Tool Call:**  
  Use `Command(resume={"action": "update", "data": {...}})` to modify the parameters of a tool call before execution. This allows you to correct or enhance the AI's suggestion.

- **Providing Feedback:**  
  Use `Command(resume={"action": "feedback", "data": <feedback string>})` to supply natural language feedback instead of manually editing the tool call. The AI then interprets this feedback and may generate a new tool call accordingly.

- **Human-in-the-Loop Advantage:**  
  Both methods empower users or supervisors to ensure that the AI's actions are accurate and relevant. This is especially critical in applications like travel planning, customer support, and other areas where precise execution matters.

By combining automation with human oversight, LangGraph creates robust systems that adapt to user needs and deliver reliable outcomes.

---

Feel free to ask if you need further clarification or additional examples!