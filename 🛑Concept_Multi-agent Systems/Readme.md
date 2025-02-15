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