# 📨 Working with Messages in Graph State

Understanding how messages work in **Graph State** is crucial when dealing with **conversation history** in **AI chat models**. Let's explore **why messages are important**, how they are used in a **graph-based system**, and the different techniques to manage them effectively.

---

## ❓ Why Use Messages?

Modern **Large Language Models (LLMs)**, such as **OpenAI's GPT models**, often use a **chat-based interface**. This means they take a **list of messages** as input rather than just a single prompt.

💡 **Key Points:**
- **LangChain's ChatModel** works with a **list of Message objects**.
- Messages can be of different types, such as:
  - **HumanMessage** → Represents user input.
  - **AIMessage** → Represents the model’s response.
- Storing conversation history as a **list of messages** is helpful for:
  - Maintaining **context** in conversations.
  - Allowing AI to **remember previous exchanges**.
  - Enabling **manual modifications** for human intervention.

---

## 🏗 Using Messages in Your Graph

When working with **graph-based conversation state**, we need to **store and manage** messages efficiently.

### **1️⃣ Storing Messages in the Graph State**
In LangChain's **Graph State**, we can store the **conversation history** by adding a key (e.g., `messages`) that holds a **list of Message objects**.

📌 **Example: Default Behavior (Overwrites Messages)**
```python
from typing_extensions import TypedDict
from langchain.schema import HumanMessage, AIMessage

class State(TypedDict):
    messages: list  # No reducer specified (Default: Overwrites)

# Initial State
state = {"messages": [HumanMessage(content="Hello!")]}

# Node sends update
state["messages"] = [AIMessage(content="Hi! How can I help?")]

print(state)
```
🔹 Here, each update **replaces** the previous messages. The old message **"Hello!"** is lost.

---

### **2️⃣ Appending Messages Using a Reducer**
Instead of **overwriting**, we can **append** new messages using **operator.add**.

📌 **Example: Appending Messages**
```python
from typing import Annotated
from typing_extensions import TypedDict
from langchain.schema import HumanMessage, AIMessage
from operator import add

class State(TypedDict):
    messages: Annotated[list, add]  # Append new messages

# Initial State
state = {"messages": [HumanMessage(content="Hello!")]}

# Node sends update (AI Response)
state["messages"] += [AIMessage(content="Hi! How can I help?")]

# User sends another message
state["messages"] += [HumanMessage(content="What is AI?")]

print(state)
```
✅ **Now, conversation history is maintained:**
```
[
    HumanMessage(content="Hello!"),
    AIMessage(content="Hi! How can I help?"),
    HumanMessage(content="What is AI?")
]
```

---

### **3️⃣ Handling Message Updates Using `add_messages`**
Sometimes, we need **manual intervention** to update **existing messages** instead of just appending them. For this, we can use the **add_messages** function.

📌 **Example: Updating Messages Without Duplicating**
```python
from langchain.memory import add_messages
from langchain.schema import HumanMessage, AIMessage

# Initial State
state = {"messages": [HumanMessage(content="Hello!", id="1")]}

# AI Responds
new_messages = [AIMessage(content="Hi! How can I help?", id="2")]

# Using add_messages to manage updates
state["messages"] = add_messages(state["messages"], new_messages)

# Updating the AI response later
updated_messages = [AIMessage(content="Hello! What do you need help with?", id="2")]
state["messages"] = add_messages(state["messages"], updated_messages)

print(state)
```
✅ **Now, instead of appending a new duplicate AI message, the previous one is updated.**

---

## 🌍 Real-World Use Cases

1️⃣ **Chatbots & Virtual Assistants**  
   - When a user interacts with a chatbot, the AI should remember the previous messages.
   - Example: **Customer Support Bot** remembers the issue a user reported.

2️⃣ **AI-powered Documentation Assistants**  
   - AI models answering questions based on conversation history.
   - Example: **AI Tutor** helping students by maintaining context.

3️⃣ **Human-in-the-Loop Review Systems**  
   - Manually adjusting AI-generated responses before they are sent.
   - Example: **AI Email Assistant** allows a human to modify responses before sending.

---

## 🔄 Summary
| Feature | Default Reducer | `operator.add` | `add_messages` |
|---------|----------------|---------------|---------------|
| Overwrites messages? | ✅ Yes | ❌ No | ❌ No |
| Appends new messages? | ❌ No | ✅ Yes | ✅ Yes |
| Can update existing messages? | ❌ No | ❌ No | ✅ Yes |

---

Now you have a **deep understanding** of how messages work in **Graph State**! 🚀