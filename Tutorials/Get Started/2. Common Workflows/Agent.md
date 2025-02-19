# 🤖 **Understanding Agents in LangChain**

Agents in LangChain allow AI models to perform complex tasks by interacting with tools in a loop based on feedback. Let’s break down this concept step by step.

---

# 🌟 **What Are Agents?**

An **Agent** is like a smart assistant that:
- Uses **tools** to complete tasks.
- Makes decisions based on **feedback** from its environment.
- Works in a **loop** until the desired outcome is achieved.

### 💡 **Key Points:**
- Agents handle **complex tasks** that require multiple steps.
- They are **autonomous**, meaning they decide which tools to use.
- The loop continues until the task is completed correctly.

### 🎯 **Real-Life Example:**
Imagine a personal assistant who:
1. Checks your calendar (tool 1).
2. Books a flight (tool 2).
3. Orders a cab (tool 3).

The assistant will:
- Check if each step was successful.
- Move to the next step or fix issues if needed.

---

# 🕒 **When Should You Use Agents?**

Agents are best for:

✅ **Open-ended tasks**: Problems where the number of steps isn’t fixed.  
✅ **Complex decision-making**: Tasks that need logical decisions at each step.  
✅ **Autonomous workflows**: When you want the AI to work with minimal supervision.

### 📝 **Example Use Cases:**
- Automated customer support.
- Data processing pipelines.
- Personalized shopping assistants.

---

# 🛠 **Tools in Agents**

Agents rely on **tools** to perform specific actions. Let’s define some simple tools.

### ⚙️ **Step 1: Defining Tools**
```python
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

@tool
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

@tool
def divide(a: int, b: int) -> float:
    """Divide two numbers."""
    return a / b
```

### 🔍 **Explanation:**
- Each function performs a basic arithmetic operation.
- The `@tool` decorator tells LangChain that these functions are available for the agent to use.

---

# 🔗 **Connecting Tools to the Agent**

Now, let’s bind these tools to our language model (LLM).

```python
# Augment the LLM with tools
tools = [add, multiply, divide]
tools_by_name = {tool.name: tool for tool in tools}
llm_with_tools = llm.bind_tools(tools)
```

### 💬 **Explanation:**
- We create a list of tools.
- Use a dictionary (`tools_by_name`) for quick access.
- **Bind** these tools to the LLM so it can use them during execution.

---

# 🤔 **How the Agent Works (Step by Step)**

### ⚡ **Step 2: LLM Decides Which Tool to Use**
```python
from langchain_core.messages import SystemMessage, HumanMessage, BaseMessage, ToolCall

@task
def call_llm(messages: list[BaseMessage]):
    """LLM decides whether to call a tool or not."""
    return llm_with_tools.invoke(
        [SystemMessage(content="You are a helpful assistant performing arithmetic tasks.")] + messages
    )
```

### 💬 **Explanation:**
- The LLM receives a system instruction and user messages.
- Based on these messages, it decides which tool to call.

### 🛠 **Step 3: Performing the Tool Call**
```python
@task
def call_tool(tool_call: ToolCall):
    """Performs the tool call."""
    tool = tools_by_name[tool_call["name"]]
    return tool.invoke(tool_call)
```

### 💬 **Explanation:**
- The chosen tool is executed with the given parameters.

---

# 🔄 **Step 4: The Agent Loop**

This loop continues until the LLM no longer needs to call a tool.

```python
@entrypoint()
def agent(messages: list[BaseMessage]):
    llm_response = call_llm(messages).result()

    while True:
        if not llm_response.tool_calls:
            break  # Exit loop if no more tools are needed

        # Execute tools
        tool_result_futures = [call_tool(tool_call) for tool_call in llm_response.tool_calls]
        tool_results = [fut.result() for fut in tool_result_futures]
        messages = add_messages(messages, [llm_response, *tool_results])
        llm_response = call_llm(messages).result()

    messages = add_messages(messages, llm_response)
    return messages
```

### 💬 **Explanation:**
- The **while loop** checks if the LLM wants to call a tool.
- It **executes** the tool and **updates** the messages.
- The loop **ends** when no more tools are required.

---

# 🚀 **Step 5: Running the Agent**

Let’s see the agent in action with a simple arithmetic task.

```python
# Invoke the agent
messages = [HumanMessage(content="Add 3 and 4.")]
for chunk in agent.stream(messages, stream_mode="updates"):
    print(chunk)
    print("\n")
```

### 🎉 **Output:**
```
Human: Add 3 and 4.
Agent: Using add tool...
Tool output: 7
Final Answer: 7
```

---

# 🌈 **Real-World Applications of Agents**

### 🏦 **1. Financial Calculators**
- Agents can calculate loans, interests, and budgets based on user inputs.

### 🤖 **2. Customer Support Bots**
- Handling user queries by accessing different databases and tools.

### 🚀 **3. Automated Data Pipelines**
- Cleaning, processing, and analyzing data step by step.

### 🎮 **4. Game AI**
- Making decisions based on player actions and game state.

---

# 🌟 **Key Takeaways**

✅ Agents perform complex, multi-step tasks by interacting with tools.  
✅ The **feedback loop** allows them to adapt their approach.  
✅ Suitable for open-ended, dynamic tasks requiring decision-making.  

💬 *Let me know if you’d like more advanced scenarios or integrations explained further!*





```python
from langchain_core.tools import tool


# Define tools
@tool
def multiply(a: int, b: int) -> int:
    """Multiply a and b.

    Args:
        a: first int
        b: second int
    """
    return a * b


@tool
def add(a: int, b: int) -> int:
    """Adds a and b.

    Args:
        a: first int
        b: second int
    """
    return a + b


@tool
def divide(a: int, b: int) -> float:
    """Divide a and b.

    Args:
        a: first int
        b: second int
    """
    return a / b


# Augment the LLM with tools
tools = [add, multiply, divide]
tools_by_name = {tool.name: tool for tool in tools}
llm_with_tools = llm.bind_tools(tools)

```


# Complete Code of Functional API (beta)
I
```python
from langgraph.graph import add_messages
from langchain_core.messages import (
    SystemMessage,
    HumanMessage,
    BaseMessage,
    ToolCall,
)


@task
def call_llm(messages: list[BaseMessage]):
    """LLM decides whether to call a tool or not"""
    return llm_with_tools.invoke(
        [
            SystemMessage(
                content="You are a helpful assistant tasked with performing arithmetic on a set of inputs."
            )
        ]
        + messages
    )


@task
def call_tool(tool_call: ToolCall):
    """Performs the tool call"""
    tool = tools_by_name[tool_call["name"]]
    return tool.invoke(tool_call)


@entrypoint()
def agent(messages: list[BaseMessage]):
    llm_response = call_llm(messages).result()

    while True:
        if not llm_response.tool_calls:
            break

        # Execute tools
        tool_result_futures = [
            call_tool(tool_call) for tool_call in llm_response.tool_calls
        ]
        tool_results = [fut.result() for fut in tool_result_futures]
        messages = add_messages(messages, [llm_response, *tool_results])
        llm_response = call_llm(messages).result()

    messages = add_messages(messages, llm_response)
    return messages

# Invoke
messages = [HumanMessage(content="Add 3 and 4.")]
for chunk in agent.stream(messages, stream_mode="updates"):
    print(chunk)
    print("\n")

```


# Complete Code of Graph AP
```python

from langgraph.graph import MessagesState
from langchain_core.messages import SystemMessage, HumanMessage, ToolMessage


# Nodes
def llm_call(state: MessagesState):
    """LLM decides whether to call a tool or not"""

    return {
        "messages": [
            llm_with_tools.invoke(
                [
                    SystemMessage(
                        content="You are a helpful assistant tasked with performing arithmetic on a set of inputs."
                    )
                ]
                + state["messages"]
            )
        ]
    }


def tool_node(state: dict):
    """Performs the tool call"""

    result = []
    for tool_call in state["messages"][-1].tool_calls:
        tool = tools_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))
    return {"messages": result}


# Conditional edge function to route to the tool node or end based upon whether the LLM made a tool call
def should_continue(state: MessagesState) -> Literal["environment", END]:
    """Decide if we should continue the loop or stop based upon whether the LLM made a tool call"""

    messages = state["messages"]
    last_message = messages[-1]
    # If the LLM makes a tool call, then perform an action
    if last_message.tool_calls:
        return "Action"
    # Otherwise, we stop (reply to the user)
    return END


# Build workflow
agent_builder = StateGraph(MessagesState)

# Add nodes
agent_builder.add_node("llm_call", llm_call)
agent_builder.add_node("environment", tool_node)

# Add edges to connect nodes
agent_builder.add_edge(START, "llm_call")
agent_builder.add_conditional_edges(
    "llm_call",
    should_continue,
    {
        # Name returned by should_continue : Name of next node to visit
        "Action": "environment",
        END: END,
    },
)
agent_builder.add_edge("environment", "llm_call")

# Compile the agent
agent = agent_builder.compile()

# Show the agent
display(Image(agent.get_graph(xray=True).draw_mermaid_png()))

# Invoke
messages = [HumanMessage(content="Add 3 and 4.")]
messages = agent.invoke({"messages": messages})
for m in messages["messages"]:
    m.pretty_print()

```