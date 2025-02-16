# 🔥 Multi-Agent Architectures in LangGraph: Handoffs & Supervisors

In multi-agent systems, different agents work together to achieve a task. These agents can communicate using **handoffs**, where control is transferred from one agent to another. In this guide, we will explore different **multi-agent architectures**, including **network-based** and **supervisor-based** approaches, using **LangGraph**. 

We'll cover:
1. ✅ **Handoffs between agents**  
2. ✅ **Network architecture (many-to-many communication)**  
3. ✅ **Supervisor-based architecture (centralized control)**  
4. ✅ **Supervisor (tool-calling) pattern**  

Each section includes **detailed explanations, real-world examples, and Python code with explanations**.  

---

## 🏆 1. Handoffs Between Agents
### 🔹 What Are Handoffs?
In multi-agent interactions, an **agent hands off control** to another agent. This means:
- **Destination**: Specifies which agent to call next.  
- **Payload**: Data passed between agents, like state updates.

👉 **Real-world Example:**  
Imagine a **customer service chatbot** that first asks for details and then routes the conversation to a **human agent** if it cannot handle the request.

---

### 💻 Code Example: Basic Handoff in LangGraph

```python
from langgraph.graph import Command
from typing import Literal

def agent(state) -> Command[Literal["agent", "another_agent"]]:
    # Determine the next agent dynamically
    goto = get_next_agent(...)  # Returns either "agent" or "another_agent"

    return Command(
        goto=goto,  # Routes to the selected agent
        update={"conversation_status": "in_progress"}  # Updates the state
    )
```

### 🔍 **Explanation**:
1. **Determine the next agent** → Uses a function (`get_next_agent`) to decide the next agent.
2. **Route execution** → `goto` sets the next agent.
3. **Update state** → Adds `"conversation_status": "in_progress"` to track the conversation.

👉 **Real-world Application:**  
Used in **automated workflows**, such as:
- Routing support tickets to the correct department.
- AI chatbots handing off tasks to specialized bots.

---

## 🌐 2. Network-Based Architecture
### 🔹 What Is a Network Architecture?
In a **network architecture**, multiple agents **communicate freely** in a **many-to-many** fashion.  
This is useful when there is **no clear sequence** of agent interactions.

👉 **Real-world Example:**  
A **multi-bot AI assistant** where:
- One bot handles **search queries**.
- Another bot handles **calendar scheduling**.
- A third bot handles **email responses**.
- Any bot can call any other bot.

---

### 💻 Code Example: Network Architecture

```python
from typing import Literal
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, MessagesState, START, END

model = ChatOpenAI()

def agent_1(state: MessagesState) -> Command[Literal["agent_2", "agent_3", END]]:
    response = model.invoke(...)  # LLM decides next step
    return Command(
        goto=response["next_agent"],  # Move to next agent
        update={"messages": [response["content"]]}  # Store response
    )

def agent_2(state: MessagesState) -> Command[Literal["agent_1", "agent_3", END]]:
    response = model.invoke(...)
    return Command(
        goto=response["next_agent"],
        update={"messages": [response["content"]]},
    )

def agent_3(state: MessagesState) -> Command[Literal["agent_1", "agent_2", END]]:
    response = model.invoke(...)
    return Command(
        goto=response["next_agent"],
        update={"messages": [response["content"]]},
    )

# Create a graph of agents
builder = StateGraph(MessagesState)
builder.add_node(agent_1)
builder.add_node(agent_2)
builder.add_node(agent_3)

builder.add_edge(START, "agent_1")  # Start with agent_1
network = builder.compile()
```

### 🔍 **Explanation**:
1. **Agents dynamically communicate** → No fixed order, each agent can call another.
2. **Graph structure** → Agents are nodes, and edges define possible transitions.
3. **LLM decides the next agent** → Based on responses.

👉 **Real-world Application:**  
- **AI-powered customer service bots** that switch between multiple AI assistants.
- **Multi-agent data processing** where agents fetch, clean, and analyze data collaboratively.

---

## 🎯 3. Supervisor-Based Architecture
### 🔹 What Is a Supervisor?
In a **supervisor architecture**, there is a central **supervisor agent** that **decides which agent should execute next**.  
This is useful when **one AI model needs to control multiple sub-agents**.

👉 **Real-world Example:**  
- An **AI project manager** assigning tasks to specialized **AI workers**.
- A **legal AI system** where a **supervisor bot** assigns cases to specialized **law AI agents**.

---

### 💻 Code Example: Supervisor-Based Architecture

```python
from typing import Literal
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, MessagesState, START, END

model = ChatOpenAI()

def supervisor(state: MessagesState) -> Command[Literal["agent_1", "agent_2", END]]:
    response = model.invoke(...)  # Supervisor decides next agent
    return Command(goto=response["next_agent"])

def agent_1(state: MessagesState) -> Command[Literal["supervisor"]]:
    response = model.invoke(...)  
    return Command(goto="supervisor", update={"messages": [response]})

def agent_2(state: MessagesState) -> Command[Literal["supervisor"]]:
    response = model.invoke(...)  
    return Command(goto="supervisor", update={"messages": [response]})

# Build the supervisor-controlled graph
builder = StateGraph(MessagesState)
builder.add_node(supervisor)
builder.add_node(agent_1)
builder.add_node(agent_2)

builder.add_edge(START, "supervisor")  # Start with supervisor
supervisor_graph = builder.compile()
```

### 🔍 **Explanation**:
1. **Supervisor decides agent execution** → Calls `invoke` to determine which agent to execute next.
2. **Agents return results** → After processing, agents return to the supervisor.
3. **Graph structure** → Agents are **subordinates**, the supervisor manages the flow.

👉 **Real-world Application:**  
- **AI-driven workflow automation**, where a manager AI assigns tasks to worker AIs.
- **Healthcare AI**, where a central AI routes patient queries to specialized medical bots.

---

## 🛠️ 4. Supervisor (Tool-Calling) Pattern
### 🔹 What Is the Tool-Calling Supervisor?
In this variant, **each agent is treated as a tool**, and the **supervisor calls them like functions**.  
This is similar to **how LLM-based assistants (like ChatGPT plugins) work**.

👉 **Real-world Example:**  
- A **coding AI assistant** where the **supervisor bot** decides:
  - If a request should go to **Python Agent** or **JavaScript Agent**.

---

### 💻 Code Example: Supervisor with Tool-Calling

```python
from typing import Annotated
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import InjectedState, create_react_agent

model = ChatOpenAI()

# Define AI tools (agents)
def agent_1(state: Annotated[dict, InjectedState]):
    response = model.invoke(...)  
    return response.content  # Return AI response

def agent_2(state: Annotated[dict, InjectedState]):
    response = model.invoke(...)  
    return response.content  # Return AI response

# Register agents as tools
tools = [agent_1, agent_2]

# Create a supervisor agent with tool-calling
supervisor = create_react_agent(model, tools)
```

### 🔍 **Explanation**:
1. **Agents act as tools** → AI tools perform specialized tasks.
2. **Supervisor decides which tool to call** → Uses `create_react_agent()`.
3. **Output is returned** → No explicit routing needed.

👉 **Real-world Application:**  
- **AI-powered software development assistants** (e.g., GitHub Copilot, ChatGPT plugins).
- **Medical AI that suggests treatments based on symptoms**.

---

## 🎯 **Conclusion**
We explored:
✅ **Handoffs** (Routing control between agents).  
✅ **Network-based architecture** (Decentralized, flexible communication).  
✅ **Supervisor-based architecture** (Centralized, structured execution).  
✅ **Supervisor with tool-calling** (AI acting as function-call manager).  

Which architecture do you want to implement? 🚀 Let me know!