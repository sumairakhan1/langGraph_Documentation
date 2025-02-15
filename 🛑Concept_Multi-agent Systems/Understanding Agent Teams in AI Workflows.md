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