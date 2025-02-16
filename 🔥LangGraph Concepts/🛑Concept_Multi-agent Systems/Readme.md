# 🌟 **Understanding LangGraph & Multi-Agent Systems** 🚀  

Multi-agent systems are a powerful way to break down complex AI workflows into smaller, manageable units. In this guide, we’ll explore **LangGraph**, **multi-agent systems**, their benefits, different architectures, and provide real-world examples and code explanations.  

---

## 🧠 **What is a Multi-Agent System?**  
A **multi-agent system** consists of multiple **independent AI agents** that work together to solve complex problems. These agents can specialize in different tasks, communicate with each other, and make intelligent decisions based on the given input.

### 📌 **Why Use Multi-Agent Systems?**  
As AI applications grow in complexity, a **single agent** may struggle to handle all tasks efficiently. Here are some common challenges:  
🔹 **Too Many Tools** → A single agent may not make the best decision on which tool to use.  
🔹 **Complex Context** → One agent might not track all relevant information.  
🔹 **Need for Specialization** → Some tasks require expertise (e.g., a **math solver**, a **planner**, a **researcher**).  

👉 **Solution:** **Break the system into multiple specialized agents!**  

---

## 🔥 **Benefits of Multi-Agent Systems**  
✅ **Modularity** → Each agent can be tested and updated independently.  
✅ **Specialization** → Agents can focus on specific areas (e.g., a **data retrieval agent**, a **summarization agent**).  
✅ **Control** → You decide how agents communicate instead of relying on an LLM’s internal logic.  

---

## 🌍 **Real-World Use Cases of Multi-Agent Systems**  
📌 **Chatbots with Multiple Roles**  
A customer support bot may have:  
- A **Billing Agent** for payment inquiries.  
- A **Technical Support Agent** for troubleshooting.  
- A **Recommendation Agent** for suggesting new products.  

📌 **AI Research Assistant**  
An AI system could have:  
- A **Web Scraper Agent** to gather information.  
- A **Summarizer Agent** to condense findings.  
- A **Planner Agent** to decide the next research step.  

📌 **Automated Coding Assistants**  
A system could include:  
- A **Bug Detector Agent** to find errors.  
- A **Code Optimizer Agent** to improve efficiency.  
- A **Documentation Agent** to generate code explanations.  

---

## 🔄 **Multi-Agent System Architectures**  

### 1️⃣ **Network Architecture**  
💡 **Each agent can communicate with every other agent.** Any agent can decide which other agent to call next.  

📌 **Example:**  
A team of AI assistants working together in a research project, where different agents can request information from each other.  

### 2️⃣ **Supervisor Architecture**  
💡 **A single "Supervisor" agent controls which agent to call next.**  

📌 **Example:**  
A chatbot where the main bot decides whether to pass the request to a **Billing Bot** or **Support Bot**.  

### 3️⃣ **Supervisor (Tool-Calling) Architecture**  
💡 **A Supervisor uses a tool-calling LLM to decide which agent to call.**  

📌 **Example:**  
A **code-generation AI** where a main agent decides whether to call the **Code-Completion Agent** or **Bug-Fixing Agent**.  

### 4️⃣ **Hierarchical Architecture**  
💡 **A Supervisor of Supervisors manages agents in a layered structure.**  

📌 **Example:**  
A **corporate AI system** where department-specific supervisors (Marketing AI, HR AI) report to a central AI system.  

### 5️⃣ **Custom Multi-Agent Workflow**  
💡 **Some agents communicate only with specific agents in a semi-deterministic way.**  

📌 **Example:**  
An **AI-powered medical diagnosis system** where a **symptom analysis agent** connects to a **specialist AI** (e.g., cardiology, neurology) based on input symptoms.  

---

## 🏗 **Code Example: Building a Multi-Agent System with LangGraph**  

Now, let’s implement a simple **multi-agent system** using LangGraph. We will create:  
- A **Math Agent** for calculations.  
- A **Research Agent** for fetching information.  
- A **Supervisor Agent** to decide which agent to use.  

### **Step 1: Install LangGraph**  
```bash
pip install langgraph langchain openai
```

### **Step 2: Define the Agents**
```python
import langgraph
from langchain.chat_models import ChatOpenAI
from langchain.schema import SystemMessage, HumanMessage

# Define LLM model
llm = ChatOpenAI(model="gpt-4")

# Define the Math Agent
def math_agent(inputs):
    question = inputs["question"]
    response = llm.invoke([HumanMessage(content=f"Calculate: {question}")])
    return {"answer": response.content}

# Define the Research Agent
def research_agent(inputs):
    topic = inputs["question"]
    response = llm.invoke([HumanMessage(content=f"Search and summarize: {topic}")])
    return {"answer": response.content}
```

📌 **Explanation:**  
🔹 We create two agents: **Math Agent** and **Research Agent**.  
🔹 Each agent processes a different type of query.  
🔹 They use `llm.invoke()` to send requests to OpenAI’s GPT model.  

---

### **Step 3: Implement the Supervisor Agent**  
```python
def supervisor_agent(inputs):
    question = inputs["question"]
    
    # Simple logic to decide which agent to call
    if any(char.isdigit() for char in question):
        return {"route": "math_agent"}
    else:
        return {"route": "research_agent"}
```
📌 **Explanation:**  
🔹 The **Supervisor Agent** decides whether to send the query to the **Math Agent** (if numbers are detected) or the **Research Agent**.  

---

### **Step 4: Create the Multi-Agent Workflow**  
```python
from langgraph.graph import StateGraph

# Define the schema for passing data
class AgentState(langgraph.GraphState):
    question: str
    answer: str

# Create the graph
workflow = StateGraph(AgentState)

# Add nodes (agents)
workflow.add_node("math_agent", math_agent)
workflow.add_node("research_agent", research_agent)
workflow.add_node("supervisor", supervisor_agent)

# Define edges (who connects to whom)
workflow.set_entry_point("supervisor")
workflow.add_edge("supervisor", "math_agent", condition=lambda x: x["route"] == "math_agent")
workflow.add_edge("supervisor", "research_agent", condition=lambda x: x["route"] == "research_agent")

# Compile the workflow
app = workflow.compile()
```

📌 **Explanation:**  
🔹 We define a **StateGraph** to manage agent interactions.  
🔹 **Supervisor Agent** decides the route.  
🔹 Agents are added as **nodes**, and logic flows between them using **edges**.  

---

### **Step 5: Run the Multi-Agent System**  
```python
response = app.invoke({"question": "What is the capital of France?"})
print(response)

response = app.invoke({"question": "12 + 24"})
print(response)
```
📌 **Explanation:**  
🔹 When asked about a **capital city**, it routes to the **Research Agent**.  
🔹 When asked a **math question**, it routes to the **Math Agent**.  

---

## 🎯 **Conclusion**  
✅ Multi-Agent Systems help **break down complex AI applications** into specialized agents.  
✅ LangGraph provides a structured way to **orchestrate multiple AI agents**.  
✅ Different architectures (network, supervisor, hierarchical) offer **flexibility** based on your use case.  
✅ This system is useful in **AI assistants, research tools, customer support, and automation workflows**.  

🔥 **Next Steps:**  
💡 Try extending this example by adding a **Translation Agent** or **Code-Generation Agent**! 🚀  

Would you like me to refine or expand on any part? 😊

---
# Multi-agent Systems 🤖

In this section, we’ll explore the concept of **multi-agent systems (MAS)**, diving into the theory, practical applications, and real-world examples. I’ll explain the concept in detail, including code examples to help you understand how MAS can be implemented. 

## What is a Multi-agent System?

A **multi-agent system** consists of multiple autonomous **agents**, where each agent has its own decision-making process, capabilities, and resources. The agents in a MAS can collaborate or work independently to achieve a particular goal. In a multi-agent system, agents may also interact with one another to solve complex problems.

An **agent** can be any system that uses logic (like a large language model, LLM) to decide what actions to take based on its environment or input. These decisions can influence the control flow of an application.

### Problems in Single-Agent Systems 🚨

In a **single-agent system**, all tasks and decisions are handled by a single agent. However, as the system becomes more complex, it might face several challenges:

1. **Too many tools**: The agent might have too many options or tools at its disposal, leading to poor decision-making about which tool to call next.
2. **Complex context**: A single agent might struggle with keeping track of too much information or context.
3. **Specialization**: A single agent may not be well-equipped to handle specialized tasks, like planning, researching, or mathematical computations.

### Solution: Multi-Agent Systems 💡

To address these problems, we break the problem down into **smaller independent agents** that can specialize in specific tasks. These agents can communicate with each other to share knowledge and coordinate actions.

### Benefits of Multi-agent Systems 🎯

1. **Modularity**: With independent agents, you can focus on developing smaller, more manageable parts of the system.
2. **Specialization**: Each agent can specialize in a specific domain, like planning or research, which improves system efficiency.
3. **Control**: You have better control over the communication and coordination between agents.

## Multi-agent System Architectures 🏛️

There are several ways in which agents in a multi-agent system can be structured and communicate:

### 1. **Network Architecture** 🌐

In a network architecture, every agent can communicate with every other agent. The agents can decide autonomously which other agents to call next.

### 2. **Supervisor Architecture** 👨‍💼

In a supervisor architecture, every agent communicates with a single **supervisor agent**, which makes decisions on which agent should be called next. The supervisor can be a central point of control.

### 3. **Supervisor (Tool-calling) Architecture** 🛠️

In this variant, each agent is treated as a **tool**. A supervisor agent can then call these tools, passing arguments to them as needed. This is useful when you have many specialized tools that need to be orchestrated.

### 4. **Hierarchical Architecture** 🔢

In this type of architecture, there is a **supervisor of supervisors**, creating a multi-tiered control flow. This allows for complex interactions and better control over large systems.

### 5. **Custom Multi-agent Workflow** 🛠️

In this architecture, agents communicate with only a subset of other agents, and parts of the flow are deterministic. This can be useful in cases where you want to design specific communication patterns between agents.

## Real-world Example of Multi-agent Systems 🌍

Let’s take an example of a **self-driving car system**. The car can be seen as a multi-agent system, with different agents working together to navigate the environment:

- **Navigation agent**: Plans the route.
- **Sensor agent**: Detects obstacles and gathers real-time data.
- **Decision agent**: Makes driving decisions like whether to stop or turn.
- **Communication agent**: Communicates with other cars and traffic signals.

These agents must collaborate and share information to ensure the car navigates safely. A failure in one agent, like the navigation agent, might require the decision agent to take control and plan a new route.

### Code Example: Multi-agent System Simulation

Let’s simulate a basic example in Python, where we have two agents communicating to solve a problem (like deciding which task to perform next):

```python
class Agent:
    def __init__(self, name):
        self.name = name

    def decide_task(self, task):
        print(f"{self.name} is deciding the task: {task}")
        # Simulate decision-making based on some logic
        if task == 'complex':
            return f"{self.name} decided to use specialized method."
        else:
            return f"{self.name} decided to use a simple method."


class SupervisorAgent(Agent):
    def __init__(self, name):
        super().__init__(name)

    def assign_task(self, agent, task):
        print(f"{self.name} assigns task '{task}' to {agent.name}")
        decision = agent.decide_task(task)
        return decision


# Create instances of agents
agent1 = Agent('Agent 1')
agent2 = Agent('Agent 2')

# Create supervisor
supervisor = SupervisorAgent('Supervisor')

# Supervisor assigns tasks to agents
task1 = supervisor.assign_task(agent1, 'complex')
task2 = supervisor.assign_task(agent2, 'simple')

# Output the decisions
print(task1)
print(task2)
```

### Code Explanation:

1. **Agent Class**: 
   - The `Agent` class has a `decide_task` method that simulates the agent's decision-making process. It decides what task to perform based on a simple condition.
   
2. **SupervisorAgent Class**: 
   - The `SupervisorAgent` class inherits from `Agent` and has an `assign_task` method that assigns tasks to other agents. The supervisor oversees which task is being assigned and delegates it to the appropriate agent.

3. **Creating Agents**:
   - We create instances of `Agent` (for general tasks) and `SupervisorAgent` (who controls the flow).

4. **Task Assignment**:
   - The supervisor assigns different tasks to two agents, and based on the task type (complex or simple), the agents decide the approach they should take.

### Output:

```
Supervisor assigns task 'complex' to Agent 1
Agent 1 is deciding the task: complex
Agent 1 decided to use specialized method.
Supervisor assigns task 'simple' to Agent 2
Agent 2 is deciding the task: simple
Agent 2 decided to use a simple method.
Agent 1 decided to use specialized method.
Agent 2 decided to use a simple method.
```

### Real-World Use Cases 🌟

1. **Customer Support**: In an online customer service system, different agents (like a **chatbot agent**, **FAQ agent**, **human agent**) can handle different levels of complexity in a conversation. A supervisor agent can decide which agent should handle the customer query.

2. **Supply Chain Management**: A multi-agent system could be used to optimize supply chain operations. Different agents could be in charge of inventory, shipments, or warehouse operations, with a supervisor agent coordinating all activities.

3. **Healthcare Systems**: Multiple specialized agents can work together to provide personalized care. One agent might handle patient scheduling, while another manages medical records, and a third performs diagnostics.

---

By breaking complex systems into smaller, specialized agents, **multi-agent systems** provide better control, scalability, and efficiency. You can handle more intricate decision-making processes and achieve better overall performance!

---
# 🚀 Multi-Agent Systems and LangGraph: A Beginner-Friendly Guide  

Multi-agent systems are a powerful way to design AI-driven applications where different specialized agents work together to accomplish a complex task. In this guide, we will explore **multi-agent networks** and how to implement them using **LangGraph**, a framework designed for managing agent-based workflows.  

This tutorial is beginner-friendly, with **detailed explanations, real-world examples, and step-by-step code walkthroughs**.  

---

## 📌 **What are Multi-Agent Systems?**  

A **multi-agent system** consists of multiple independent agents that communicate and collaborate to solve tasks. Each agent is specialized in a specific function, improving efficiency and decision-making.  

### 🔹 **Why Use Multi-Agent Systems?**  

✅ **Modularity** – Easier to manage and debug.  
✅ **Specialization** – Each agent has a specific role.  
✅ **Scalability** – Handles complex tasks efficiently.  
✅ **Improved Decision-Making** – Experts collaborate to reach the best solution.  

### 🔹 **Real-World Example: AI-Powered Research and Data Visualization**  

Imagine a research team where:  

1. A **Researcher Agent** gathers data.  
2. A **Data Analyst Agent** processes the data.  
3. A **Chart Generator Agent** creates visual reports.  

Instead of one agent doing everything inefficiently, these specialized agents **work together seamlessly**.  

---

## 🏗️ **Understanding Multi-Agent Networks**  

### 🛠️ **How Does a Multi-Agent Network Work?**  

Instead of a single agent handling all tasks, we use a **"divide-and-conquer"** approach. Different agents take on specific tasks and communicate to complete a job.  

#### 📊 **Example Use Case: Automated Financial Report Generation**  

Imagine an **automated system** that:  
1. **Researches GDP Data** (Research Agent)  
2. **Processes and Analyzes Data** (Data Analyst Agent)  
3. **Generates a Chart** (Chart Generator Agent)  

By designing this as a **multi-agent network**, each part of the system works independently but collaboratively.  

---

## 🚀 **Building a Multi-Agent Network Using LangGraph**  

We will now **implement a multi-agent system** that:  
1. **Gathers GDP data of the UK for the last 5 years**  
2. **Generates a line chart of the data**  

### 📌 **Step 1: Install Required Packages**  

First, install the required libraries:  

```bash
pip install -U langchain_community langchain_anthropic langchain_experimental matplotlib langgraph
```

---

### 📌 **Step 2: Set Up API Keys**  

We need API keys for **Anthropic** (LLM) and **Tavily** (Web Search).  

```python
import getpass
import os

def _set_if_undefined(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"Please provide your {var}")

_set_if_undefined("ANTHROPIC_API_KEY")
_set_if_undefined("TAVILY_API_KEY")
```

This function ensures we **securely set our API keys** if they are not already defined.  

---

### 📌 **Step 3: Define Tools for Agents**  

Agents will need tools to **search the web** and **execute Python code** for data processing.  

```python
from typing import Annotated
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.tools import tool
from langchain_experimental.utilities import PythonREPL

# Web search tool (Tavily API)
tavily_tool = TavilySearchResults(max_results=5)

# Python execution tool (REPL)
repl = PythonREPL()

@tool
def python_repl_tool(
    code: Annotated[str, "The python code to execute to generate your chart."],
):
    """Executes Python code. Use 'print()' to display output."""
    try:
        result = repl.run(code)
    except BaseException as e:
        return f"Execution Failed: {repr(e)}"
    return f"Successfully executed:\n```python\n{code}\n```\nStdout: {result}"
```

🔹 **What is happening here?**  
✅ `tavily_tool` – Searches the web for research.  
✅ `python_repl_tool` – Executes Python code to process data.  

---

### 📌 **Step 4: Create System Prompt for Agents**  

Each agent gets a **custom system prompt** to guide its role.  

```python
def make_system_prompt(suffix: str) -> str:
    return (
        "You are a helpful AI assistant collaborating with other assistants."
        " Use the provided tools to progress towards answering the question."
        " If you cannot fully answer, another assistant will help."
        " If a final answer is found, prefix your response with 'FINAL ANSWER'."
        f"\n{suffix}"
    )
```

🔹 **What is happening here?**  
✅ This function ensures that agents **collaborate efficiently** and know when to **stop**.  

---

### 📌 **Step 5: Define Research Agent**  

```python
from langchain_core.messages import BaseMessage, HumanMessage
from langchain_anthropic import ChatAnthropic
from langgraph.prebuilt import create_react_agent
from langgraph.graph import MessagesState, END
from langgraph.types import Command

llm = ChatAnthropic(model="claude-3-5-sonnet-latest")

def get_next_node(last_message: BaseMessage, goto: str):
    if "FINAL ANSWER" in last_message.content:
        return END
    return goto

# Research Agent
research_agent = create_react_agent(
    llm,
    tools=[tavily_tool],
    prompt=make_system_prompt("You can only do research.")
)

def research_node(state: MessagesState) -> Command:
    result = research_agent.invoke(state)
    goto = get_next_node(result["messages"][-1], "chart_generator")
    result["messages"][-1] = HumanMessage(content=result["messages"][-1].content, name="researcher")
    return Command(update={"messages": result["messages"]}, goto=goto)
```

🔹 **What is happening here?**  
✅ **Creates a Research Agent** to gather GDP data.  
✅ **Passes research to Chart Generator Agent** for visualization.  

---

### 📌 **Step 6: Define Chart Generator Agent**  

```python
chart_agent = create_react_agent(
    llm,
    [python_repl_tool],
    prompt=make_system_prompt("You can only generate charts.")
)

def chart_node(state: MessagesState) -> Command:
    result = chart_agent.invoke(state)
    goto = get_next_node(result["messages"][-1], "researcher")
    result["messages"][-1] = HumanMessage(content=result["messages"][-1].content, name="chart_generator")
    return Command(update={"messages": result["messages"]}, goto=goto)
```

🔹 **What is happening here?**  
✅ **Creates a Chart Agent** to generate visualizations.  
✅ **Receives research data** and processes it.  

---

### 📌 **Step 7: Define the Multi-Agent Workflow**  

```python
from langgraph.graph import StateGraph, START

workflow = StateGraph(MessagesState)
workflow.add_node("researcher", research_node)
workflow.add_node("chart_generator", chart_node)
workflow.add_edge(START, "researcher")

graph = workflow.compile()
```

🔹 **What is happening here?**  
✅ **Defines a graph** where agents communicate.  
✅ **Starts with the researcher** and moves to the chart generator.  

---

### 📌 **Step 8: Run the Multi-Agent System**  

```python
events = graph.stream(
    {
        "messages": [
            ("user", "Get the UK's GDP for the last 5 years and create a line chart.")
        ],
    },
    {"recursion_limit": 150},
)

for s in events:
    print(s)
    print("----")
```

🔹 **What is happening here?**  
✅ The **user asks for GDP data** and a **chart**.  
✅ The **research agent gathers data**.  
✅ The **chart agent visualizes the data**.  

---

## 🎯 **Conclusion**  

We have successfully built a **multi-agent system** using LangGraph! This system:  
✅ **Divides work among specialized agents**  
✅ **Improves efficiency by assigning tasks to experts**  
✅ **Creates an automated workflow for research and visualization**  

Multi-agent systems are **widely used in AI, research automation, and intelligent assistants**. 🚀  

Would you like to extend this by adding more agents? Let me know! 😊

---
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

---
Got it! I'll break this down step by step, explaining everything in a beginner-friendly way with real-world use cases, code explanations, and examples.

---

# 📌 **Hierarchical Agent Teams Explained in Depth**
Hierarchical Agent Teams are used when tasks become too complex for a single worker or when multiple workers need efficient coordination. This structure allows for **better task distribution** using a top-level supervisor and mid-level supervisors.

---

## 🎯 **Why Use Hierarchical Agent Teams?**
Imagine you are managing a **research and documentation team** for a large company. You have:
1. A **top-level manager** who oversees the project.
2. **Mid-level supervisors** for different departments (Research, Writing).
3. **Team members** working under each supervisor.

This hierarchical setup ensures:
- Work is divided efficiently.
- Communication remains structured.
- Large projects are easier to manage.

---

## 🏗 **Real-World Example**
### ✍️ Research and Documentation Team
- The **Research Team** collects data from the internet.
- The **Writing Team** organizes and formats the information into a document.
- A **Supervisor** assigns tasks and compiles the final report.

This is exactly what we implement in the given code.

---

# 🚀 **Step-by-Step Implementation**

## 🛠 **1. Setup and Dependencies**
First, we need to install necessary Python libraries.

```python
%%capture --no-stderr
%pip install -U langgraph langchain_community langchain_anthropic langchain_experimental

import getpass
import os
```
### 🔍 **What This Code Does:**
- 📥 **Installs required libraries**: `langgraph`, `langchain_community`, etc.
- 🏗 **Imports system libraries**: `getpass`, `os` for handling API keys.

---

## 🔑 **2. Setting API Keys**
To access external services like OpenAI or Tavily, we set API keys.

```python
def _set_if_undefined(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"Please provide your {var}")

_set_if_undefined("OPENAI_API_KEY")
_set_if_undefined("TAVILY_API_KEY")
```
### 🔍 **Explanation:**
- This function **checks if an API key exists**.
- If not, it **prompts the user to enter it securely**.
- `os.environ[var]` stores the key for later use.

---

## 🔍 **3. Creating Research Team Tools**
### 🔹 **Purpose:** Fetching and scraping data from the web.

```python
from typing import Annotated, List
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.tools import tool

tavily_tool = TavilySearchResults(max_results=5)

@tool
def scrape_webpages(urls: List[str]) -> str:
    """Scrape the provided web pages for detailed information."""
    loader = WebBaseLoader(urls)
    docs = loader.load()
    return "\n\n".join(
        [
            f'<Document name="{doc.metadata.get("title", "")}">\n{doc.page_content}\n</Document>'
            for doc in docs
        ]
    )
```
### 🔍 **Explanation:**
- **`tavily_tool`**: Uses **Tavily** (a search engine) to fetch results.
- **`scrape_webpages(urls)`**:
  - Uses **WebBaseLoader** to load webpages.
  - Extracts **content and metadata**.
  - Returns formatted content for further use.

### 🎯 **Real-World Use Case**
This tool is useful for:
- **Automated market research**: Scrape competitor websites for analysis.
- **News aggregation**: Gather articles on a topic.
- **Academic research**: Extract information for papers.

---

## 📄 **4. Creating Document Writing Tools**
### 🔹 **Purpose:** Creating, reading, and editing documents.

```python
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Dict, Optional
from typing_extensions import TypedDict

_TEMP_DIRECTORY = TemporaryDirectory()
WORKING_DIRECTORY = Path(_TEMP_DIRECTORY.name)
```
### 🔍 **Explanation:**
- `_TEMP_DIRECTORY` is a temporary folder for saving files.
- `WORKING_DIRECTORY` stores our document files.

---

### 📑 **4.1 Creating an Outline**
```python
@tool
def create_outline(
    points: Annotated[List[str], "List of main points or sections."],
    file_name: Annotated[str, "File path to save the outline."],
) -> Annotated[str, "Path of the saved outline file."]:
    """Create and save an outline."""
    with (WORKING_DIRECTORY / file_name).open("w") as file:
        for i, point in enumerate(points):
            file.write(f"{i + 1}. {point}\n")
    return f"Outline saved to {file_name}"
```
### 🔍 **Explanation:**
- **Creates an outline file** with bullet points.
- **Writes** each section title to the file.

### 🎯 **Use Case**
- **Book writing**: Plan chapters.
- **Content creation**: Structure blog posts.
- **Project documentation**: Organize ideas.

---

### 📖 **4.2 Reading a Document**
```python
@tool
def read_document(
    file_name: Annotated[str, "File path to read the document from."],
    start: Annotated[Optional[int], "The start line. Default is 0"] = None,
    end: Annotated[Optional[int], "The end line. Default is None"] = None,
) -> str:
    """Read the specified document."""
    with (WORKING_DIRECTORY / file_name).open("r") as file:
        lines = file.readlines()
    if start is None:
        start = 0
    return "\n".join(lines[start:end])
```
### 🔍 **Explanation:**
- Reads a document **from start to end** or a specific range.
- Useful for **reviewing saved research**.

---

### 📝 **4.3 Writing a Document**
```python
@tool
def write_document(
    content: Annotated[str, "Text content to be written into the document."],
    file_name: Annotated[str, "File path to save the document."],
) -> Annotated[str, "Path of the saved document file."]:
    """Create and save a text document."""
    with (WORKING_DIRECTORY / file_name).open("w") as file:
        file.write(content)
    return f"Document saved to {file_name}"
```
### 🔍 **Explanation:**
- Saves the given **text content** into a file.
- Can be used for **saving research summaries**.

---

### ✏️ **4.4 Editing a Document**
```python
@tool
def edit_document(
    file_name: Annotated[str, "Path of the document to be edited."],
    inserts: Annotated[
        Dict[int, str],
        "Dictionary where key is the line number (1-indexed) and value is the text to be inserted at that line.",
    ],
) -> Annotated[str, "Path of the edited document file."]:
    """Edit a document by inserting text at specific line numbers."""
    with (WORKING_DIRECTORY / file_name).open("r") as file:
        lines = file.readlines()
    sorted_inserts = sorted(inserts.items())
    for line_number, text in sorted_inserts:
        if 1 <= line_number <= len(lines) + 1:
            lines.insert(line_number - 1, text + "\n")
        else:
            return f"Error: Line number {line_number} is out of range."
    with (WORKING_DIRECTORY / file_name).open("w") as file:
        file.writelines(lines)
    return f"Document edited and saved to {file_name}"
```
### 🔍 **Explanation:**
- Inserts text at **specific line numbers**.
- Useful for **collaborative editing**.

---

## 🐍 **5. Running Python Code in the System**
```python
from langchain_experimental.utilities import PythonREPL

repl = PythonREPL()

@tool
def python_repl_tool(
    code: Annotated[str, "The python code to execute to generate your chart."],
):
    """Use this to execute python code."""
    try:
        result = repl.run(code)
    except BaseException as e:
        return f"Failed to execute. Error: {repr(e)}"
    return f"Successfully executed:\n{code}\nStdout: {result}"
```
### 🔍 **Explanation:**
- Runs **Python scripts dynamically**.
- Useful for **data processing, chart generation**.

---

## 🎯 **Conclusion**
- **Hierarchical Agent Teams** break tasks into smaller parts.
- **Research and Document Teams** work together.
- **Each function** automates part of the workflow.

Would you like a **full project example** integrating all parts? 🚀

---

# 📌 **Understanding Hierarchical Agent Teams in AI Systems**  

In this guide, we will break down the concept of **Hierarchical Agent Teams** in AI applications. We’ll explain each part of the implementation in a simple and beginner-friendly manner, with **real-world examples** and **Python code** to illustrate how it works.  

---

## 🏗 **What are Hierarchical Agent Teams?**  

In AI-driven applications, multiple agents often collaborate to complete complex tasks. Instead of having all agents work independently, **hierarchical structures** allow for **better organization, efficiency, and task delegation**.  

💡 **Example in the Real World:**  
Imagine a **news agency** that collects and writes reports:  
- A **supervisor** assigns different parts of research and writing to journalists.  
- A **research team** collects information from sources.  
- A **writing team** compiles the research into an article.  
- A **final review team** edits and finalizes the article before publishing.  

This hierarchical structure ensures a smooth workflow and prevents confusion.  

---

## 🛠 **Creating Helper Utilities for Agent Teams**  

To make it easier to create **supervisors** and **worker agents**, we define some **helper functions**. These functions:  
✅ Create **worker agents** dynamically.  
✅ Create **supervisors** that assign tasks to the right agents.  

---

## 📝 **Step-by-Step Code Breakdown**  

### 1️⃣ **Importing Required Modules**  

Before we build our AI system, let's import the necessary libraries.  

```python
from typing import List, Optional, Literal
from langchain_core.language_models.chat_models import BaseChatModel

from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.types import Command
from langchain_core.messages import HumanMessage, trim_messages
```

🔍 **Explanation:**  
- `typing` → Helps define types like `List`, `Optional`, and `Literal`.  
- `BaseChatModel` → Represents an AI language model that can chat.  
- `StateGraph`, `MessagesState` → Used to build **state-based workflows** in LangGraph.  
- `START`, `END` → Mark the **beginning** and **end** of an AI workflow.  
- `Command` → Represents actions an agent can take.  
- `HumanMessage`, `trim_messages` → Handle human-like messages in AI communication.  

---

### 2️⃣ **Defining State for Agents**  

```python
class State(MessagesState):
    next: str
```

🔍 **Explanation:**  
- `State` → This class **inherits** from `MessagesState`, meaning it stores messages exchanged in the system.  
- `next: str` → Keeps track of the **next agent or action** to execute.  

💡 **Real-World Analogy:**  
This is like a **task manager** keeping track of which worker should handle the next step in a project.  

---

### 3️⃣ **Creating a Supervisor Node**  

The **supervisor** is responsible for assigning tasks to workers.  

```python
def make_supervisor_node(llm: BaseChatModel, members: list[str]) -> str:
    options = ["FINISH"] + members
    system_prompt = (
        "You are a supervisor tasked with managing a conversation between the"
        f" following workers: {members}. Given the following user request,"
        " respond with the worker to act next. Each worker will perform a"
        " task and respond with their results and status. When finished,"
        " respond with FINISH."
    )
```

🔍 **Explanation:**  
- `make_supervisor_node(llm, members)` → Creates a **supervisor agent** using an AI model (`llm`).  
- `members: list[str]` → List of **worker agents** that can be assigned tasks.  
- `options = ["FINISH"] + members` → Adds `"FINISH"` as a possible response, meaning work is done.  
- `system_prompt` → Defines instructions for the **AI-powered supervisor**, telling it how to assign tasks.  

💡 **Real-World Analogy:**  
This is like a **team lead** reading a project request and deciding which **team member** should handle it next.  

---

### 4️⃣ **Defining How the Supervisor Routes Work**  

Now, we define a **TypedDict** to specify the structure of responses and create the supervisor function.  

```python
    class Router(TypedDict):
        """Worker to route to next. If no workers needed, route to FINISH."""
        next: Literal[*options]
```

🔍 **Explanation:**  
- `Router(TypedDict)` → Defines a dictionary structure where `next` represents **which agent should act next**.  
- `Literal[*options]` → The **next step** must be either a worker name or `"FINISH"`.  

---

### 5️⃣ **Implementing the Supervisor Logic**  

```python
    def supervisor_node(state: State) -> Command[Literal[*members, "__end__"]]:
        """An LLM-based router."""
        messages = [
            {"role": "system", "content": system_prompt},
        ] + state["messages"]
        response = llm.with_structured_output(Router).invoke(messages)
        goto = response["next"]
        if goto == "FINISH":
            goto = END

        return Command(goto=goto, update={"next": goto})
```

🔍 **Explanation:**  
- `def supervisor_node(state: State) -> Command[Literal[*members, "__end__"]]`:  
  - Defines a **supervisor function** that takes in the current **state**.  
  - Returns a `Command` that tells which agent should act next.  

- `messages = [{"role": "system", "content": system_prompt}] + state["messages"]`:  
  - Creates a **list of messages** that includes system instructions and past messages.  

- `response = llm.with_structured_output(Router).invoke(messages)`:  
  - Calls the AI model (`llm`) to decide **which agent should act next**.  
  - Ensures the output follows the `Router` structure.  

- `goto = response["next"]`:  
  - Extracts the **next worker's name** from the AI response.  

- `if goto == "FINISH": goto = END`:  
  - If the AI supervisor says `"FINISH"`, we mark the workflow as **complete**.  

- `return Command(goto=goto, update={"next": goto})`:  
  - Returns a **command** that moves the workflow to the selected worker.  

💡 **Real-World Analogy:**  
Imagine a **call center supervisor** listening to a customer request and deciding:  
- If the request is about **billing**, send it to the **Billing Team**.  
- If it's about **technical issues**, send it to the **Support Team**.  
- If everything is resolved, **end the conversation**.  

---

## 🏆 **Summary: How the Supervisor Works**  

1️⃣ The **supervisor** gets a task request.  
2️⃣ It analyzes past messages and instructions.  
3️⃣ It picks the **right worker agent** (or finishes the task).  
4️⃣ The workflow continues until **all tasks are done**.  

---

## 💡 **Real-World Applications of Hierarchical Agent Teams**  

✅ **Customer Support Bots** → Direct user queries to the right department.  
✅ **Automated Research Systems** → Collect and summarize information from different sources.  
✅ **AI-Powered Content Creation** → Research, write, and edit documents automatically.  
✅ **Robotic Process Automation (RPA)** → Distribute tasks among different AI agents.  

---

## 🎯 **Final Thoughts**  

Hierarchical Agent Teams **help manage complexity** by breaking tasks into smaller, manageable parts. Using **AI-powered supervisors**, we can create intelligent systems that **automatically assign, monitor, and complete tasks** efficiently.  

💬 **What would you like to automate using AI agent teams?** 🚀 Let’s discuss!

---
# 🧠 **Understanding Agent Teams in AI Workflows**
  
AI-powered agent teams allow us to build structured and automated workflows. These teams act like specialized units in a company, each performing a specific role, communicating, and working together under a supervisor. 

This concept is particularly useful for automating complex tasks like **researching information, web scraping, document writing, and data analysis**.

---

## 🎯 **What Are Agent Teams?**
Agent teams are a group of AI-powered agents designed to **collaborate** on tasks. Each agent has a **specific role**, such as:
- **Searching the web** for information
- **Scraping websites** for structured data
- **Writing documents** based on instructions
- **Generating charts** from extracted data

Agents follow a **hierarchical structure**, where:
1. **Worker Agents** perform individual tasks.
2. A **Supervisor Agent** coordinates and ensures smooth task flow.

This structure **mimics real-world organizations**, improving efficiency and automation.

---

## 🚀 **Real-World Example: Automated Research and Documentation System**
Imagine a company needs to:
- Collect **latest industry news** using AI.
- Extract **relevant insights** from various websites.
- Summarize and **store reports** for employees.

We can build an **AI-powered research team** that:
1. **Searches** for relevant information.
2. **Scrapes** data from trusted sources.
3. **Generates a summarized report**.
4. **Stores the report in a structured document**.

---

# 🔎 **Defining the Research Team**
The **Research Team** consists of:
- **Search Agent** 🕵️ – Finds relevant information.
- **Web Scraper Agent** 🌐 – Extracts detailed data from websites.
- **Supervisor Agent** 🏗️ – Manages and coordinates tasks.

### 📌 **Implementation in Python**
We'll use the `LangChain` framework to implement our research team.

### **🔹 Step 1: Import Necessary Libraries**
```python
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent
```
🔍 **Explanation:**
- `langchain_core.messages.HumanMessage` – Handles human-generated messages.
- `langchain_openai.ChatOpenAI` – Connects to OpenAI’s language model.
- `langgraph.prebuilt.create_react_agent` – Creates AI-powered agents that react to tasks.

---

### **🔹 Step 2: Create Search Agent**
```python
llm = ChatOpenAI(model="gpt-4o")  # Use GPT-4o model

search_agent = create_react_agent(llm, tools=[tavily_tool])

def search_node(state: State) -> Command[Literal["supervisor"]]:
    result = search_agent.invoke(state)
    return Command(
        update={"messages": [HumanMessage(content=result["messages"][-1].content, name="search")]},
        goto="supervisor",  # After searching, send results to the supervisor
    )
```
🔍 **Explanation:**
- **`ChatOpenAI(model="gpt-4o")`** initializes the AI model.
- **`create_react_agent(llm, tools=[tavily_tool])`** creates a search agent using an external search API (`tavily_tool`).
- **`search_node(state: State)`** defines the search agent's function.
  - Calls the **search agent** to fetch data.
  - Stores the last message as `search` output.
  - Reports back to the **Supervisor Agent**.

---

### **🔹 Step 3: Create Web Scraper Agent**
```python
web_scraper_agent = create_react_agent(llm, tools=[scrape_webpages])

def web_scraper_node(state: State) -> Command[Literal["supervisor"]]:
    result = web_scraper_agent.invoke(state)
    return Command(
        update={"messages": [HumanMessage(content=result["messages"][-1].content, name="web_scraper")]},
        goto="supervisor",  # After scraping, send results to the supervisor
    )
```
🔍 **Explanation:**
- **`create_react_agent(llm, tools=[scrape_webpages])`** – Creates an agent that extracts data from websites.
- **`web_scraper_node(state: State)`**:
  - Calls the **Web Scraper Agent**.
  - Stores extracted data as `web_scraper` output.
  - Reports back to the **Supervisor Agent**.

---

### **🔹 Step 4: Create Supervisor Agent**
```python
research_supervisor_node = make_supervisor_node(llm, ["search", "web_scraper"])
```
🔍 **Explanation:**
- `make_supervisor_node(llm, ["search", "web_scraper"])` creates a **Supervisor Agent** that manages both **search** and **web scraping** tasks.

---

### **🔹 Step 5: Define Workflow Graph**
```python
from langgraph.graph import StateGraph

research_builder = StateGraph(State)
research_builder.add_node("supervisor", research_supervisor_node)
research_builder.add_node("search", search_node)
research_builder.add_node("web_scraper", web_scraper_node)

research_builder.add_edge(START, "supervisor")  # Start execution at supervisor

research_graph = research_builder.compile()
```
🔍 **Explanation:**
- **`StateGraph(State)`** – Defines a stateful workflow.
- **`add_node("supervisor", research_supervisor_node)`** – Adds supervisor to manage agents.
- **`add_node("search", search_node)`** – Adds the search agent.
- **`add_node("web_scraper", web_scraper_node)`** – Adds the web scraper agent.
- **`add_edge(START, "supervisor")`** – Execution starts at **Supervisor**.

---

### **🔹 Step 6: Run the Research Team**
```python
for s in research_graph.stream({"messages": [("user", "when is Taylor Swift's next tour?")]}, {"recursion_limit": 100}):
    print(s)
    print("---")
```
🔍 **Explanation:**
- **Passes a user query**: "when is Taylor Swift’s next tour?"
- **Agents process the query in sequence**:
  1. **Search Agent** fetches initial results.
  2. **Web Scraper Agent** extracts detailed info.
  3. **Supervisor Agent** finalizes the response.

---

# 📄 **Defining the Document Writing Team**
The **Document Writing Team** automates content creation. It includes:
- **Note-Taking Agent** 📝 – Creates outlines.
- **Document Writer Agent** 📄 – Writes structured documents.
- **Chart Generator Agent** 📊 – Generates visual insights.
- **Supervisor Agent** 🏗️ – Manages tasks.

### 📌 **Implementation Steps**
1. **Initialize AI Model**
```python
llm = ChatOpenAI(model="gpt-4o")
```

2. **Define Note-Taking Agent**
```python
note_taking_agent = create_react_agent(llm, tools=[create_outline, read_document])
```
- Reads documents and creates outlines.

3. **Define Document Writer Agent**
```python
doc_writer_agent = create_react_agent(llm, tools=[write_document, edit_document, read_document])
```
- Writes and edits structured documents.

4. **Define Chart Generator Agent**
```python
chart_generating_agent = create_react_agent(llm, tools=[read_document, python_repl_tool])
```
- Reads documents and generates charts.

5. **Define Supervisor**
```python
doc_writing_supervisor_node = make_supervisor_node(llm, ["doc_writer", "note_taker", "chart_generator"])
```
- Coordinates writing tasks.

6. **Define Workflow Graph**
```python
paper_writing_builder = StateGraph(State)
paper_writing_builder.add_node("supervisor", doc_writing_supervisor_node)
paper_writing_builder.add_node("doc_writer", doc_writing_node)
paper_writing_builder.add_node("note_taker", note_taking_node)
paper_writing_builder.add_node("chart_generator", chart_generating_node)

paper_writing_graph = paper_writing_builder.compile()
```

7. **Run Document Writing Task**
```python
for s in paper_writing_graph.stream({"messages": [("user", "Write an outline for poem about cats and then write the poem to disk.")]}, {"recursion_limit": 100}):
    print(s)
    print("---")
```
---

# 🎯 **Key Takeaways**
✅ **Agent Teams** automate research, document writing, and data extraction.  
✅ **Supervisor Agents** manage the flow of tasks efficiently.  
✅ **Real-World Use Cases**: AI-powered research assistants, automated report generation, content summarization.

🚀 **With AI agent teams, we can automate complex workflows and boost productivity!**

---
# 📌 **Understanding Graph Layers and Routing Work Between Graphs**  

When working with complex workflows, we often need a structured way to distribute tasks among multiple subgroups or teams. This is where **graph-based architectures** come in. By **adding layers** to a system, we can implement a **top-down planning policy** that allows a supervisor (a top-level entity) to coordinate multiple teams efficiently.  

In this guide, we'll **deeply explore** the concepts of **layering graphs** and **routing work** in a hierarchical manner. We'll **break down** the provided code, explain each line, discuss **real-world applications**, and provide **alternative examples** to strengthen your understanding.  

---

## 🏗 **Concept: Adding Layers to a Graph-Based System**  

### 🔹 **What are Layers in a Graph-Based System?**  
Layers represent **different levels of decision-making**. Instead of all components interacting directly, we introduce **an orchestrator** (a top layer) that distributes work among different sub-graphs (lower layers).  

### 🔹 **Why Use Layers?**  
1. **Improved Organization** 🏢 – Helps structure different responsibilities (e.g., Research Team, Writing Team).  
2. **Better Control** 🎛 – The supervisor ensures work is **distributed properly**.  
3. **Scalability** 📈 – More teams (sub-graphs) can be added without changing the entire system.  

### 🔹 **Real-World Example: Research and Writing Teams**  
Consider a company that writes **technical reports**. The workflow is divided as follows:  
- **Research Team** 🔍 – Collects and analyzes information.  
- **Writing Team** ✍️ – Writes the report based on research findings.  
- **Supervisor** 🏗 – Coordinates both teams and ensures smooth workflow.  

This layered approach ensures that work is **efficiently divided** and **managed** without conflicts.  

---

## 📝 **Breaking Down the Code: Line-by-Line Explanation**  

### 📌 **Step 1: Import Required Libraries**  
```python
from langchain_core.messages import BaseMessage
```
🔹 **Purpose:**  
- `BaseMessage` is a foundational class for handling messages in LangChain.  
- It allows agents (like Research and Writing Teams) to **communicate** via a **shared state**.  

---

### 📌 **Step 2: Initialize the Language Model**  
```python
llm = ChatOpenAI(model="gpt-4o")
```
🔹 **Purpose:**  
- We initialize **ChatOpenAI** using the latest GPT-4o model.  
- This **large language model (LLM)** helps process and generate text-based responses.  

---

### 📌 **Step 3: Create the Supervisor Node**  
```python
teams_supervisor_node = make_supervisor_node(llm, ["research_team", "writing_team"])
```
🔹 **Purpose:**  
- Creates a **supervisor agent** that oversees two teams:  
  1. `"research_team"` 🔍  
  2. `"writing_team"` ✍️  
- This supervisor **decides which team to call next** based on the workflow.  

---

### 📌 **Step 4: Define the Research Team Function**  
```python
def call_research_team(state: State) -> Command[Literal["supervisor"]]:
    response = research_graph.invoke({"messages": state["messages"][-1]})
```
🔹 **Purpose:**  
- Calls the **research graph** and provides it with the latest user message.  
- **state["messages"][-1]** retrieves the **most recent message** in the state.  

```python
    return Command(
        update={
            "messages": [
                HumanMessage(
                    content=response["messages"][-1].content, name="research_team"
                )
            ]
        },
        goto="supervisor",
    )
```
🔹 **Purpose:**  
- **Updates the state** by adding the research team’s response to the message list.  
- Sets **goto="supervisor"**, meaning once research is done, control is returned to the supervisor.  

---

### 📌 **Step 5: Define the Writing Team Function**  
```python
def call_paper_writing_team(state: State) -> Command[Literal["supervisor"]]:
    response = paper_writing_graph.invoke({"messages": state["messages"][-1]})
```
🔹 **Purpose:**  
- Similar to the research function but calls the **writing graph** instead.  

```python
    return Command(
        update={
            "messages": [
                HumanMessage(
                    content=response["messages"][-1].content, name="writing_team"
                )
            ]
        },
        goto="supervisor",
    )
```
🔹 **Purpose:**  
- Updates the state with the **writing team’s response**.  
- Returns control back to the supervisor.  

---

### 📌 **Step 6: Define the Graph and Connect Nodes**  
```python
super_builder = StateGraph(State)
super_builder.add_node("supervisor", teams_supervisor_node)
super_builder.add_node("research_team", call_research_team)
super_builder.add_node("writing_team", call_paper_writing_team)
```
🔹 **Purpose:**  
- Creates a **StateGraph**, which manages different nodes (teams).  
- Adds the **supervisor** and both teams as nodes.  

---

### 📌 **Step 7: Define How Nodes Interact**  
```python
super_builder.add_edge(START, "supervisor")
super_graph = super_builder.compile()
```
🔹 **Purpose:**  
- **Defines workflow**:  
  - The **starting point** (`START`) is connected to the **supervisor**.  
  - The **supervisor** then routes tasks to the correct team.  

---

### 📌 **Step 8: Display the Graph (Visualization)**  
```python
from IPython.display import Image, display

display(Image(super_graph.get_graph().draw_mermaid_png()))
```
🔹 **Purpose:**  
- Uses **Mermaid.js** to generate a **visual representation** of the workflow.  

---

### 📌 **Step 9: Run the Graph with Sample Input**  
```python
for s in super_graph.stream(
    {
        "messages": [
            ("user", "Research AI agents and write a brief report about them.")
        ],
    },
    {"recursion_limit": 150},
):
    print(s)
    print("---")
```
🔹 **Purpose:**  
- **Sends a message** ("Research AI agents and write a brief report about them.")  
- The supervisor routes this to the research team first, then the writing team.  
- **Prints each step** of the workflow.  

---

## 🌟 **Alternative Examples for Deeper Understanding**  

### 🏥 **Example 1: Hospital Workflow**  
- **Supervisor:** Doctor  
- **Research Team:** Lab Technicians (analyze patient tests)  
- **Writing Team:** Medical Scribes (document patient history)  
- **Implementation:**  
  - Doctor asks for tests → Lab sends results → Scribe updates records  

---

### 📚 **Example 2: Publishing a Book**  
- **Supervisor:** Publishing Editor  
- **Research Team:** Authors (write book content)  
- **Writing Team:** Proofreaders (edit and format content)  
- **Implementation:**  
  - Author writes chapters → Editor reviews → Proofreader finalizes  

---

### 🛒 **Example 3: E-Commerce Order Processing**  
- **Supervisor:** Order Management System  
- **Research Team:** Warehouse (checks stock availability)  
- **Writing Team:** Logistics Team (arranges delivery)  
- **Implementation:**  
  - Order is placed → Warehouse confirms stock → Logistics team ships the order  

---

## 🎯 **Key Takeaways**  
✅ **Layering graphs** helps structure complex workflows efficiently.  
✅ **Supervisor nodes** ensure proper task distribution.  
✅ **State management** is crucial for effective communication between teams.  
✅ **Alternative examples** help in grasping real-world applications.  

---

## 💡 **Final Thoughts**  
Understanding **graph-based architectures** is essential for designing **scalable, structured workflows**. Whether you're building **AI-powered research tools, hospital management systems, or e-commerce platforms**, the same **principles of layered graphs** can be applied.  

Would you like to implement a custom version of this system for a **specific use case**? 🚀

---

# 🏗️ **Understanding Handoffs in Multi-Agent Architectures**  

## 🔍 **Introduction**  
In multi-agent architectures, agents (autonomous systems or AI components) communicate with each other to complete complex tasks. Instead of one agent handling everything, different agents specialize in different functions and **handoff** tasks to each other as needed.  

This concept is widely used in AI, automation, and large-scale system design. **Handoffs** allow smooth transitions between agents, ensuring efficient workflow management.  

### 🎯 **Real-World Example: AI Customer Support System**  
Imagine an AI-based customer support system where:  
1. **Chatbot (Agent A)** answers common questions.  
2. **Billing Agent (Agent B)** handles payment-related issues.  
3. **Human Support (Agent C)** takes over complex issues.  

Using **handoffs**, the chatbot can **transfer** a billing-related query to the billing agent or escalate it to human support when needed. This ensures that each agent only handles the tasks they specialize in.  

---

# 🛠️ **Understanding Handoffs in LangChain**  
In **LangChain**, agents are represented as **nodes in a graph**. These nodes can:  
✅ Perform tasks  
✅ Decide whether to continue execution  
✅ Pass control to another agent  

This is done using **Command objects**, which define:  
- 📍 **Destination:** Where the control should go next.  
- 📦 **Payload:** What information should be passed to the next agent.  

---

## 🔄 **Basic Handoff Between Two Agents**  
Let's implement a **handoff** where an **AI Researcher agent** hands off a task to a **Report Writer agent**.  

### ✅ **Code Example: Basic Handoff Between Two Agents**  

```python
from typing import Literal
from langchain_core.messages import HumanMessage
from langchain_core.state import State
from langchain_core.graphs import StateGraph, Command

# Define AI Research Agent
def research_agent(state: State) -> Command[Literal["research_agent", "writing_agent"]]:
    """
    Simulates an AI research agent processing a task and handing off to a writing agent.
    """
    print("🧠 Research Agent: Conducting research...")
    
    # Simulating research output
    research_output = "AI agents are used in various applications like chatbots, automation, and self-driving cars."

    # Determine next step: Handing off to the writing agent
    return Command(
        goto="writing_agent",  # Handoff to the writing agent
        update={"research_data": research_output}  # Pass research data
    )

# Define AI Writing Agent
def writing_agent(state: State) -> Command[Literal["research_agent", "writing_agent"]]:
    """
    Simulates an AI writing agent generating a report based on research data.
    """
    research_content = state.get("research_data", "No research data available.")
    print("✍️ Writing Agent: Writing report based on research...")

    # Generating a report
    report = f"Summary Report: {research_content}"
    
    return Command(
        goto="writing_agent",  # Could loop to itself for revisions or stop execution
        update={"final_report": report}
    )

# Build the Graph
workflow = StateGraph(State)
workflow.add_node("research_agent", research_agent)
workflow.add_node("writing_agent", writing_agent)
workflow.add_edge("research_agent", "writing_agent")

# Compile the workflow
handoff_graph = workflow.compile()

# Execute the workflow
for step in handoff_graph.stream({}, {"recursion_limit": 5}):
    print(step)
    print("---")
```

### 📝 **Code Breakdown:**  
- **🔹 `research_agent(state)`**  
  - Simulates an AI that conducts research.  
  - It generates a research summary and **hands off** the task to the **writing agent** using `Command`.  
  - The `goto="writing_agent"` ensures the next step is the writing phase.  
  - `update={"research_data": research_output}` passes data to the next agent.  

- **🔹 `writing_agent(state)`**  
  - Receives research data and writes a summary report.  
  - The `state.get("research_data")` fetches data from the previous step.  
  - `goto="writing_agent"` allows **self-looping** if further revisions are needed.  

- **🔹 `StateGraph`**  
  - A directed graph managing the workflow.  
  - Nodes are added using `add_node()`.  
  - The connection (`handoff`) between the nodes is defined using `add_edge()`.  

- **🔹 `handoff_graph.stream()`**  
  - Runs the workflow step by step.  
  - The `"recursion_limit": 5` ensures the loop does not run indefinitely.  

---

## 🔗 **Handoff Between Multiple Agents (Subgraphs)**  
Sometimes, an agent can have its own **subgraph** (a graph inside a graph). This allows finer control over multi-agent workflows.  

### ✅ **Example: AI Workflow with Subgraphs**  

```python
def some_node_inside_research(state):
    """
    Handles a specific research step and hands off to another agent.
    """
    return Command(
        goto="writing_agent",
        update={"research_data": "Advanced AI research insights"},
        graph=Command.PARENT  # Navigates back to the parent workflow
    )
```

### 🔍 **Key Concept: `graph=Command.PARENT`**  
- Used when **an agent inside a subgraph** needs to navigate **back to the main workflow**.  
- Ensures smooth transitions between **nested agents**.  

---

## 🔧 **Using Handoffs in Tool-Based Agents**  
A common use case is when **agents act as tools** that can be invoked dynamically.  

### ✅ **Example: Using Handoffs as Tools**  

```python
def transfer_to_bob(state):
    """
    Transfers execution to the Bob agent.
    """
    return Command(
        goto="bob",
        update={"task": "Processing transferred data"},
        graph=Command.PARENT
    )
```

### 🔍 **Key Takeaways:**  
✔️ The agent **transfers control** to another agent (`bob`).  
✔️ The **task data** is passed as an update.  
✔️ `graph=Command.PARENT` ensures proper workflow transition.  

---

# 📌 **Why Use Handoffs?**  
Handoffs improve **scalability** and **modularity** in AI workflows. Instead of a single **monolithic** agent, we use **specialized agents** that delegate tasks efficiently.  

### 🏆 **Benefits:**  
✅ **Improves Efficiency** – Each agent focuses on its **specialty**.  
✅ **Enables Collaboration** – Multiple agents can work together seamlessly.  
✅ **Scalability** – Adding new agents becomes easy.  
✅ **Better Debugging** – Isolating agent failures is simpler.  

---

# 🔥 **Real-World Applications of Handoffs**  

| 🏢 Industry | 📌 Use Case |
|------------|------------|
| 🎙️ **Customer Support** | Chatbot hands off to a human for complex issues. |
| 📜 **Content Writing** | AI researcher hands off to a writing assistant. |
| 🔎 **Cybersecurity** | Threat detection system escalates to an analyst. |
| 🤖 **Automation Pipelines** | One AI module hands off to another for specialized processing. |
| 📊 **Financial Systems** | AI checks fraud patterns and escalates to human auditors. |

---

# 🎯 **Final Thoughts**  
Handoffs allow multiple agents to **collaborate effectively**, ensuring **smooth execution** in AI-driven workflows. They are widely used in **customer service**, **document processing**, **cybersecurity**, and **automated decision-making**.  

💡 **Next Steps:** Try building your own multi-agent system using LangChain's `StateGraph` and `Command` objects! 🚀  

Would you like to see a **more complex multi-agent system** example with **real-world use cases**? Let me know! 😊

---
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


----

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

---
# 🧩 **Understanding Graph State vs Tool Calls in Multi-Agent Systems**  

When designing multi-agent systems, one of the key considerations is **how agents communicate**. There are two primary approaches:  

1. **Graph State Communication** (agents share state updates directly)  
2. **Tool Calls** (agents call specific tools to perform tasks and pass arguments)  

Let's explore these in detail with **real-world examples, code snippets, and explanations** to make the concept clear.  

---

## 🔷 **What is Graph State?**  
In **Graph State Communication**, agents communicate by passing around a **shared state**. Each agent updates this state before passing it to the next agent in the system.  

### 📌 **How it Works:**  
- Each agent is a **node in the graph**.  
- The **state is passed from node to node**, with updates applied at each step.  
- Agents may **share a common state schema** or have their own **private state schemas**.  

### 🏢 **Real-World Example: Workflow Automation System**  
Imagine a **document approval process** in a company:  
1. **Employee submits a request** → Document is sent to a Supervisor.  
2. **Supervisor reviews and approves/rejects** → If approved, it goes to HR.  
3. **HR processes the document** → Updates company records.  

Each step modifies the **shared state** (document status, comments, approvals) and passes it forward.  

---

## 🛠 **Graph State Communication in LangGraph (Code Example)**  
Let's define a **graph-based system** where agents communicate via state.  

### **1️⃣ Defining the State Schema**  
We define a `MessagesState` class, which holds the messages exchanged between agents.  

```python
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.types import Command

model = ChatOpenAI()

# Define state schema (shared between agents)
class CustomState(MessagesState):
    next: str  # Defines which agent to call next
```

### **2️⃣ Implementing the Agents**  
Each agent updates the **shared state** before passing it to the next agent.  

```python
def agent_1(state: CustomState) -> Command[str]:
    """Agent 1 processes input and decides the next step."""
    response = model.invoke({"input": state.messages})  # Simulate AI processing
    return Command(goto="agent_2", update={"messages": [response]})

def agent_2(state: CustomState) -> Command[str]:
    """Agent 2 receives updated state and processes further."""
    response = model.invoke({"input": state.messages})
    return Command(goto="agent_3", update={"messages": [response]})

def agent_3(state: CustomState) -> Command[str]:
    """Final agent processes the final response and completes the workflow."""
    response = model.invoke({"input": state.messages})
    return Command(goto=END, update={"messages": [response]})
```

### **3️⃣ Constructing the Workflow Graph**  
We define a **graph of nodes** that determines the flow of execution.  

```python
# Build the workflow graph
builder = StateGraph(CustomState)

# Add agents as nodes
builder.add_node(agent_1)
builder.add_node(agent_2)
builder.add_node(agent_3)

# Define flow between nodes
builder.add_edge(START, "agent_1")
builder.add_edge("agent_1", "agent_2")
builder.add_edge("agent_2", "agent_3")
builder.add_edge("agent_3", END)

# Compile the graph
workflow_graph = builder.compile()
```

### ✅ **What Happens Here?**
1. **Agent 1** processes input and updates the state.  
2. **Agent 2** gets the updated state and continues processing.  
3. **Agent 3** completes the workflow and ends execution.  

This is an example of **deterministic, structured communication**.

---

## 🔶 **What are Tool Calls?**
In **Tool Calls Communication**, instead of sharing state directly, agents use **function calls (tools)** to perform tasks.  

### 📌 **How it Works:**  
- A **supervisor agent** decides which tools to call.  
- Each tool takes **specific inputs**, performs a task, and returns results.  
- The **supervisor dynamically determines execution order** based on the inputs.  

### 🚗 **Real-World Example: AI-Powered Customer Support**  
Consider an **AI-based customer service chatbot**:  
1. User asks a question.  
2. The AI determines which tool to use:  
   - **FAQ Lookup Tool** (if it's a common question)  
   - **Ticket Creation Tool** (if it requires human support)  
   - **Billing Inquiry Tool** (if it's a payment issue)  
3. The AI calls the selected tool and returns a response.  

---

## 🛠 **Tool Calls in LangGraph (Code Example)**  

### **1️⃣ Defining the Supervisor**
The **supervisor** decides which tool (agent) to call.  

```python
def supervisor(state: MessagesState) -> Command[str]:
    """Decides which tool (agent) to call based on user input."""
    response = model.invoke({"input": state.messages})
    
    # Example decision-making based on response type
    if "billing" in response:
        return Command(goto="billing_tool")
    elif "support" in response:
        return Command(goto="support_tool")
    else:
        return Command(goto=END)
```

### **2️⃣ Implementing the Tools**
Each **tool performs a specific task** and returns results.  

```python
def billing_tool(state: MessagesState) -> Command[str]:
    """Handles billing-related inquiries."""
    response = model.invoke({"input": state.messages})
    return Command(goto="supervisor", update={"messages": [response]})

def support_tool(state: MessagesState) -> Command[str]:
    """Handles technical support inquiries."""
    response = model.invoke({"input": state.messages})
    return Command(goto="supervisor", update={"messages": [response]})
```

### **3️⃣ Constructing the Tool-Based Workflow**
```python
# Build the graph
builder = StateGraph(MessagesState)

# Add supervisor and tools as nodes
builder.add_node(supervisor)
builder.add_node("billing_tool", billing_tool)
builder.add_node("support_tool", support_tool)

# Define flow between nodes
builder.add_edge(START, "supervisor")
builder.add_edge("billing_tool", "supervisor")
builder.add_edge("support_tool", "supervisor")

# Compile the graph
tool_graph = builder.compile()
```

### ✅ **What Happens Here?**
1. The **supervisor** decides which tool to call.  
2. The selected **tool processes the request**.  
3. The tool **returns results** to the supervisor for further decisions.  

This is an example of **dynamic execution**, where the **flow is determined at runtime**.

---

## 🔥 **Graph State vs Tool Calls: When to Use What?**
| Feature | Graph State | Tool Calls |
|---------|------------|------------|
| **Best for** | Structured workflows | Dynamic decision-making |
| **Execution flow** | Predefined | Decided at runtime |
| **Communication** | Shared state | Function calls |
| **Scalability** | Can become complex with many agents | Easier to scale dynamically |

---

## 🎯 **Key Takeaways**
- **Graph State**: Best for structured workflows where agents follow a predefined sequence.  
- **Tool Calls**: Best for dynamic decision-making where the supervisor picks the next tool to call.  
- **Hybrid Approach**: You can **combine both approaches**, using a **supervisor to manage a structured graph of agents**.  

### 🚀 **Next Steps**
- Try **modifying the code** to handle different workflows.  
- Implement a **hybrid model** where some agents use **state-based communication**, and others use **tool calls**.  
- Explore **memory management strategies** for handling **large-scale agent networks**.  

Would you like a **detailed breakdown** of **memory management techniques** for multi-agent systems next? 🤖💡