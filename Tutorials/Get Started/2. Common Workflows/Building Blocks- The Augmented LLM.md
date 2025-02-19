# 🚀 **Understanding Workflows and Agents in Agentic Systems**  

Agentic systems are gaining popularity in AI because they make AI models smarter by helping them manage complex tasks. To fully understand how these systems work, we need to explore two key concepts: **Workflows** and **Agents**. We will cover these concepts with real-world examples, detailed code explanations, and step-by-step breakdowns.  

---

## 🌟 **What are Workflows?**  

### 💡 **Definition:**  
**Workflows** are **predefined sequences of tasks** that an AI model (LLM) and tools follow. They are like recipes—each step is planned in advance.  

### 🌍 **Real-World Example:**  
Imagine an **e-commerce website** where a customer places an order. The workflow could look like this:  
1. ✅ Confirm the order.  
2. 🚚 Arrange shipping.  
3. 💳 Process the payment.  
4. 📩 Send an email confirmation.  

Each step follows a fixed sequence without any decision-making by the system.  

---

## 🤖 **What are Agents?**  

### 💡 **Definition:**  
**Agents** are AI systems that can **decide what to do next** based on the task. They can dynamically choose which tools to use and how to complete tasks.  

### 🌍 **Real-World Example:**  
Consider a **virtual travel assistant** helping you plan a vacation. It can:  
- ✈️ Suggest flights based on your preferences.  
- 🏨 Recommend hotels based on your budget.  
- 🍽️ Book restaurants depending on your dietary needs.  

Unlike workflows, the agent adapts its actions based on your inputs and changing conditions.  

---

## 🔄 **Key Differences Between Workflows and Agents**  

| ⚡ **Feature**      | 🛠️ **Workflows**                          | 🤖 **Agents**                          |
|---------------------|-------------------------------------------|-----------------------------------------|
| **Task Control**    | Predefined by developers                  | Dynamically decided by the AI           |
| **Flexibility**     | Low (fixed sequence)                      | High (can adapt based on context)       |
| **Example**         | Order processing in e-commerce            | Personal assistant for trip planning    |
| **Complexity**      | Simple to moderate                        | Complex (needs decision-making ability) |

---

## 🛠️ **Setting Up the Environment**  

Before we start building, we need to set up our environment by installing necessary packages and initializing our model.  

### 🔧 **Step 1: Install Dependencies**  
```bash
pip install langchain langchain-anthropic pydantic
```
- `langchain`: Framework for building LLM-powered applications.  
- `langchain-anthropic`: Integration for using Anthropic's LLM.  
- `pydantic`: Helps in creating data models for structured outputs.  

---

### 🗝️ **Step 2: Initialize the LLM**  
```python
import os
import getpass
from langchain_anthropic import ChatAnthropic

# 🔑 Function to set the API key securely
def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

# 🚀 Setting the API key for Anthropic's model
_set_env("ANTHROPIC_API_KEY")

# 🤖 Initializing the Claude model from Anthropic
llm = ChatAnthropic(model="claude-3-5-sonnet-latest")
```

### 🔍 **Explanation:**  
- **`_set_env` function:** Checks if the API key exists in the environment; if not, it prompts the user.  
- **`ChatAnthropic` model:** Initializes the Claude-3-5 Sonnet model, which is a conversational AI model from Anthropic.  

---

## 🏗️ **Building Blocks: The Augmented LLM**  

### ✨ **What is an Augmented LLM?**  
An **augmented LLM** can:  
- ✅ Provide **structured outputs** (well-defined data instead of just plain text).  
- 🛠️ Use **tools** like calculators or search functions.  

---

### 📝 **Step 3: Structured Outputs with Pydantic**  
```python
from pydantic import BaseModel, Field

# 📚 Defining a schema for structured output
class SearchQuery(BaseModel):
    search_query: str = Field(None, description="Query optimized for web search.")
    justification: str = Field(None, description="Why this query is relevant.")

# 🔗 Augmenting the LLM with the structured output schema
structured_llm = llm.with_structured_output(SearchQuery)

# 🔍 Invoking the augmented LLM
output = structured_llm.invoke("How does Calcium CT score relate to high cholesterol?")

# 📤 Displaying the output
print(output)
```

### 💡 **Explanation:**  
- **`SearchQuery` class:** Defines a model with two fields:  
  - `search_query`: The actual search string.  
  - `justification`: The reason for choosing this search.  
- **`with_structured_output`:** Tells the LLM to return data in this structured format.  
- **`invoke`:** Calls the LLM with a question and gets structured results.  

### 🌍 **Real-World Use Case:**  
A **healthcare assistant** using structured outputs to search for relevant medical information based on user symptoms.  

---

### ⚡ **Step 4: Tool Calling in LLM**  

#### 🔢 **Example: Basic Math Tool**  
```python
# 🔧 Defining a simple multiplication tool
def multiply(a: int, b: int) -> int:
    return a * b

# 🧩 Augmenting the LLM with the multiplication tool
llm_with_tools = llm.bind_tools([multiply])

# 🚀 Invoking the LLM with a query that uses the tool
msg = llm_with_tools.invoke("What is 2 times 3?")

# 🔎 Displaying the tool call output
print(msg.tool_calls)
```

### 💡 **Explanation:**  
- **`multiply` function:** A simple function to multiply two numbers.  
- **`bind_tools`:** Attaches the tool to the LLM, so it can use it when needed.  
- **`invoke`:** The LLM intelligently decides to use the `multiply` function for the query.  

### 🌍 **Real-World Use Case:**  
A **financial assistant** calculating loan payments or investment growth based on user input.  

---

## 🧭 **Key Takeaways**  
- **Workflows:** Fixed, sequential processes suitable for repetitive tasks.  
- **Agents:** Flexible, decision-making systems ideal for complex, dynamic scenarios.  
- **LangGraph + Langchain:** Help build workflows and agents with features like persistence, debugging, and deployment.  
- **Augmented LLM:** Enhanced LLM with structured outputs and tool-calling abilities.  

---

## 🎯 **Conclusion**  
Understanding how to build workflows and agents using LLMs opens up countless possibilities. From healthcare and e-commerce to finance and personal assistance, these systems enable AI to handle complex, real-world tasks efficiently.  

Would you like more advanced examples or real-world project ideas on this topic? 😊