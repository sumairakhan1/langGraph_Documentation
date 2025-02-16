# 🌟 Multi-Agent Supervisor in LangGraph: A Beginner-Friendly Deep Dive  

## 🧠 Introduction  

In AI-powered applications, multiple agents often collaborate to accomplish complex tasks. A **multi-agent supervisor** helps coordinate these agents by delegating tasks effectively.  

This guide will walk you through how to:  
✅ Use **LangGraph** to orchestrate multiple AI agents  
✅ Implement a **supervisor agent** to manage workflows  
✅ Utilize **prebuilt agent tools** like web research and code execution  
✅ Construct a **graph-based workflow**  

We'll explain **each concept in simple terms**, with **real-world use cases**, and **code examples with explanations** to help you understand **what’s happening at each step**.  

---

## 🔍 **What is a Multi-Agent Supervisor?**  

A **multi-agent supervisor** is like a **project manager** in a company. Instead of manually handling tasks, it **delegates work to different AI agents** and decides when the task is complete.  

💡 **Real-World Use Case:**  
Imagine you are building an **AI assistant for data analysis**. When a user asks for economic insights:  
1️⃣ One agent searches for the latest GDP data  
2️⃣ Another agent calculates the average  
3️⃣ The **supervisor** ensures these tasks are executed in order  

This structured delegation prevents confusion and enhances efficiency! 🚀  

---

## 🛠 **Step 1: Setting Up the Environment**  

Before coding, install the necessary **Python libraries** for working with LangGraph and AI models:  

```python
%%capture --no-stderr
%pip install -U langgraph langchain_community langchain_anthropic langchain_experimental
```

These libraries help us:  
✅ **LangGraph** – Manage workflows between multiple AI agents  
✅ **LangChain Community** – Connect with various tools  
✅ **LangChain Anthropic** – Use **Claude** LLM for decision-making  

Next, set up **API keys** for secure access:  

```python
import getpass
import os

def _set_if_undefined(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"Please provide your {var}")

_set_if_undefined("ANTHROPIC_API_KEY")  # API key for Claude AI
_set_if_undefined("TAVILY_API_KEY")     # API key for search tools
```

🔍 **Why?** This ensures we securely store API credentials without exposing them in our code.

---

## 🔎 **Step 2: Creating AI Agents**  

We will create **two specialized AI agents**:  
📌 **Research Agent** – Searches the web for relevant information  
📌 **Coder Agent** – Executes Python code  

### ✨ **Defining AI Tools**  

To allow our agents to interact with the web and execute code, we define the tools:  

```python
from typing import Annotated
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.tools import tool
from langchain_experimental.utilities import PythonREPL

# Web Search Tool
tavily_tool = TavilySearchResults(max_results=5)

# Python Code Execution Tool
repl = PythonREPL()
```

### 🖥 **Why These Tools?**  
- **TavilySearchResults** helps the research agent fetch online data 📊  
- **PythonREPL** allows the coder agent to run calculations and generate charts 📈  

---

## 🤖 **Step 3: Building a Supervisor Agent**  

The **Supervisor Agent** makes intelligent decisions about **which agent should act next** or when the task is complete.  

```python
from typing import Literal
from typing_extensions import TypedDict

from langchain_anthropic import ChatAnthropic
from langgraph.graph import MessagesState, END
from langgraph.types import Command

members = ["researcher", "coder"]
options = members + ["FINISH"]

# Supervisor's instructions
system_prompt = (
    "You are a supervisor managing a conversation between"
    f" these workers: {members}. Assign the next worker to act."
    " When finished, return FINISH."
)

class Router(TypedDict):
    """Determine the next worker. FINISH if all tasks are done."""
    next: Literal[*options]

llm = ChatAnthropic(model="claude-3-5-sonnet-latest")

class State(MessagesState):
    next: str

def supervisor_node(state: State) -> Command[Literal[*members, "__end__"]]:
    messages = [{"role": "system", "content": system_prompt}] + state["messages"]
    response = llm.with_structured_output(Router).invoke(messages)
    
    goto = response["next"]
    if goto == "FINISH":
        goto = END  # Marks completion

    return Command(goto=goto, update={"next": goto})
```

🔍 **Explanation:**  
✅ The **Supervisor Agent** reads messages from agents and users  
✅ It **decides** which agent should act next  
✅ If all tasks are done, it **signals the workflow to finish**  

---

## 🔗 **Step 4: Connecting Agents in a Workflow**  

Now, we define the **research agent** and **coder agent**, connecting them in a structured workflow.  

### 🧑‍💻 **Research Agent**  

```python
from langchain_core.messages import HumanMessage
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import create_react_agent

# Creating research agent
research_agent = create_react_agent(
    llm, tools=[tavily_tool], prompt="You are a researcher. DO NOT do any math."
)

def research_node(state: State) -> Command[Literal["supervisor"]]:
    result = research_agent.invoke(state)
    return Command(
        update={
            "messages": [
                HumanMessage(content=result["messages"][-1].content, name="researcher")
            ]
        },
        goto="supervisor",
    )
```

### 🖥 **Coder Agent**  

```python
# Creating coder agent
code_agent = create_react_agent(llm, tools=[python_repl_tool])

def code_node(state: State) -> Command[Literal["supervisor"]]:
    result = code_agent.invoke(state)
    return Command(
        update={
            "messages": [
                HumanMessage(content=result["messages"][-1].content, name="coder")
            ]
        },
        goto="supervisor",
    )
```

🔍 **Explanation:**  
1️⃣ **Research Agent** retrieves information 📊  
2️⃣ **Coder Agent** processes it (e.g., calculations, plotting graphs) 📈  
3️⃣ **Supervisor Agent** decides the workflow 🔄  

---

## 🚀 **Step 5: Building the Graph Workflow**  

We now construct the **StateGraph** to connect the supervisor and agents.  

```python
builder = StateGraph(State)
builder.add_edge(START, "supervisor")
builder.add_node("supervisor", supervisor_node)
builder.add_node("researcher", research_node)
builder.add_node("coder", code_node)

graph = builder.compile()
```

🔍 **Explanation:**  
✅ **StateGraph** represents our workflow 🔄  
✅ **START** -> **Supervisor** -> **Researcher / Coder**  
✅ **Supervisor decides** the execution flow  

---

## 🎯 **Step 6: Running the Multi-Agent System**  

Let's test it by asking a **mathematical and research-based question**.  

```python
for s in graph.stream(
    {"messages": [("user", "What's the square root of 42?")]}, subgraphs=True
):
    print(s)
    print("----")
```

```python
for s in graph.stream(
    {
        "messages": [
            (
                "user",
                "Find the latest GDP of New York and California, then calculate the average",
            )
        ]
    },
    subgraphs=True,
):
    print(s)
    print("----")
```

🔍 **Expected Output:**  
✅ The **researcher** fetches the latest GDP data  
✅ The **coder** calculates the average  
✅ The **supervisor** ensures proper execution  

---

## 🎉 **Conclusion**  

✅ We **built a multi-agent supervisor** that manages different AI agents  
✅ Used **LangGraph** for structuring workflows  
✅ Created **research & coder agents** to handle tasks  
✅ Tested the system with **real-world queries**  

This approach is **scalable** and can be extended with more agents for complex AI-driven automation! 🚀  

Would you like additional improvements or customization? Let me know! 😊