# 🏗️ **Understanding Hierarchical Multi-Agent Systems with LangGraph**  

## 🧐 **What is a Hierarchical Multi-Agent System?**  
A **hierarchical multi-agent system** is a way to manage multiple AI agents efficiently. Instead of having a single supervisor handle all agents, we group agents into specialized **teams** with their own supervisors. A **top-level supervisor** then manages these teams, making decisions on which team to call based on the situation.  

This approach is useful when dealing with complex decision-making scenarios where a single supervisor would struggle to track and manage all agents effectively.  

### 🎯 **Real-World Applications**
Hierarchical multi-agent systems are widely used in:  
1. **Customer Support Bots**: Teams of bots handle different query types (billing, technical support, order tracking).  
2. **Autonomous Vehicles**: A central system manages groups of self-driving cars in different regions.  
3. **Manufacturing**: Supervisors assign tasks to specialized robots in different sections of a factory.  

---

## 🏗️ **Building a Hierarchical Multi-Agent System with LangGraph**  
We'll implement a system where:  
1. We have **two teams of agents** (Team 1 and Team 2).  
2. Each team has a **supervisor** that decides which agent should be called next.  
3. A **top-level supervisor** manages both teams.  

### 🔹 **Step 1: Import Required Modules**  
```python
from typing import Literal
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.types import Command
```
✅ **What is happening here?**  
- `Literal`: Helps define possible values for commands.  
- `ChatOpenAI`: A wrapper to interact with OpenAI models.  
- `StateGraph`: Allows us to define workflows (which agent is called next).  
- `MessagesState`: Maintains the conversation state.  
- `START` and `END`: Define the beginning and end of a workflow.  
- `Command`: Used to dynamically determine the next step.  

---

### 🔹 **Step 2: Define Team 1**
#### 🧑‍💼 **Team 1 Supervisor**  
```python
model = ChatOpenAI()

def team_1_supervisor(state: MessagesState) -> Command[Literal["team_1_agent_1", "team_1_agent_2", END]]:
    response = model.invoke(...)  
    return Command(goto=response["next_agent"])
```
✅ **What is happening here?**  
- The `team_1_supervisor` function calls the AI model (`ChatOpenAI`) to decide which agent should be called next.  
- It returns a `Command` that routes to `"team_1_agent_1"`, `"team_1_agent_2"`, or `END`.  

#### 🏃 **Team 1 Agents**  
```python
def team_1_agent_1(state: MessagesState) -> Command[Literal["team_1_supervisor"]]:
    response = model.invoke(...)
    return Command(goto="team_1_supervisor", update={"messages": [response]})

def team_1_agent_2(state: MessagesState) -> Command[Literal["team_1_supervisor"]]:
    response = model.invoke(...)
    return Command(goto="team_1_supervisor", update={"messages": [response]})
```
✅ **Explanation:**  
- **Agents process tasks** and return responses.  
- They always return control back to `team_1_supervisor`.  

#### 🏗 **Build Team 1 Workflow**
```python
team_1_builder = StateGraph(MessagesState)
team_1_builder.add_node(team_1_supervisor)
team_1_builder.add_node(team_1_agent_1)
team_1_builder.add_node(team_1_agent_2)
team_1_builder.add_edge(START, "team_1_supervisor")
team_1_graph = team_1_builder.compile()
```
✅ **Explanation:**  
- **Creates a workflow** for Team 1.  
- The flow starts at `team_1_supervisor`.  
- The graph is compiled into `team_1_graph`.  

---

### 🔹 **Step 3: Define Team 2 (Similar to Team 1)**
```python
class Team2State(MessagesState):
    next: Literal["team_2_agent_1", "team_2_agent_2", "__end__"]

def team_2_supervisor(state: Team2State):
    ...

def team_2_agent_1(state: Team2State):
    ...

def team_2_agent_2(state: Team2State):
    ...

team_2_builder = StateGraph(Team2State)
...
team_2_graph = team_2_builder.compile()
```
✅ **Key Differences:**  
- Uses `Team2State` to manage state.  
- Agents behave similarly to Team 1.  

---

### 🔹 **Step 4: Define the Top-Level Supervisor**  
```python
def top_level_supervisor(state: MessagesState) -> Command[Literal["team_1_graph", "team_2_graph", END]]:
    response = model.invoke(...)
    return Command(goto=response["next_team"])
```
✅ **What is happening here?**  
- The **top-level supervisor** decides whether to call **Team 1 or Team 2** based on the AI model's decision.  
- If `"__end__"` is returned, the process stops.  

---

### 🔹 **Step 5: Build the Final Hierarchical Graph**
```python
builder = StateGraph(MessagesState)
builder.add_node(top_level_supervisor)
builder.add_node("team_1_graph", team_1_graph)
builder.add_node("team_2_graph", team_2_graph)
builder.add_edge(START, "top_level_supervisor")
builder.add_edge("team_1_graph", "top_level_supervisor")
builder.add_edge("team_2_graph", "top_level_supervisor")
graph = builder.compile()
```
✅ **Explanation:**  
- We define the **top-level workflow** where the supervisor decides which team to call.  
- Teams return control to the supervisor after completing tasks.  
- The graph is compiled for execution.  

---

## 🏗 **Custom Multi-Agent Workflow in LangGraph**
This architecture allows **explicit control flow** (predefined sequence) or **dynamic control flow** (AI decides the sequence).  

### 🔹 **Example: Custom Multi-Agent Workflow**  
```python
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, MessagesState, START

model = ChatOpenAI()

def agent_1(state: MessagesState):
    response = model.invoke(...)
    return {"messages": [response]}

def agent_2(state: MessagesState):
    response = model.invoke(...)
    return {"messages": [response]}

builder = StateGraph(MessagesState)
builder.add_node(agent_1)
builder.add_node(agent_2)
# Define explicit control flow
builder.add_edge(START, "agent_1")
builder.add_edge("agent_1", "agent_2")
```
✅ **Explanation:**  
- **Agent 1 executes first**, then Agent 2.  
- The workflow is **deterministic** because we manually define the sequence.  

---

## 📢 **Key Takeaways**
1️⃣ **Hierarchical multi-agent systems** improve scalability by organizing agents into specialized teams.  
2️⃣ **Top-level supervisors** manage teams and make decisions on execution order.  
3️⃣ **LangGraph allows both deterministic and dynamic workflows** for better flexibility.  
4️⃣ **Used in real-world applications** like AI-powered support, robotics, and self-driving systems.  

Would you like a **more advanced example** or help with a **specific use case**? 🚀