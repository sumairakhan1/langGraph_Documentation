# Utilities¶
 
Define helper functions to pretty print the messages in the graph while we debug it and to give our tool node error handling (by adding the error to the chat history).

```python
from langchain_core.messages import ToolMessage
from langchain_core.runnables import RunnableLambda

from langgraph.prebuilt import ToolNode


def handle_tool_error(state) -> dict:
    error = state.get("error")
    tool_calls = state["messages"][-1].tool_calls
    return {
        "messages": [
            ToolMessage(
                content=f"Error: {repr(error)}\n please fix your mistakes.",
                tool_call_id=tc["id"],
            )
            for tc in tool_calls
        ]
    }


def create_tool_node_with_fallback(tools: list) -> dict:
    return ToolNode(tools).with_fallbacks(
        [RunnableLambda(handle_tool_error)], exception_key="error"
    )


def _print_event(event: dict, _printed: set, max_length=1500):
    current_state = event.get("dialog_state")
    if current_state:
        print("Currently in: ", current_state[-1])
    message = event.get("messages")
    if message:
        if isinstance(message, list):
            message = message[-1]
        if message.id not in _printed:
            msg_repr = message.pretty_repr(html=True)
            if len(msg_repr) > max_length:
                msg_repr = msg_repr[:max_length] + " ... (truncated)"
            print(msg_repr)
            _printed.add(message.id)

```

# 🌟 **Understanding Utility Functions for Error Handling and Debugging**  

This guide explains how utility functions are used for debugging and error handling in Python, specifically within applications using **LangChain** and **LangGraph**. We'll break down each function, provide real-world use cases, and explain the code line by line.  

---

## 🌍 **Real-World Example**  
Imagine you're building a **travel chatbot** that helps users plan trips. When the chatbot calls external tools (like flight or hotel booking APIs), errors might occur (e.g., "destination not found"). These **utility functions** ensure:  
1. **Clear error messages** are shown.  
2. **Errors are logged** for debugging.  
3. **The system can recover** from some errors instead of crashing.  

---

## 🔧 **Key Utility Functions Explained**  

### 1️⃣ **`handle_tool_error` – Handling Errors Gracefully**  
This function creates readable error messages when a tool fails.  

### 💡 **Why is it needed?**  
Without this, users might see technical errors that are hard to understand. We want **user-friendly** feedback.  

### 💻 **Code Example & Explanation:**
```python
def handle_tool_error(state) -> dict:
    error = state.get("error")  # 📌 Extract the error from the state
    tool_calls = state["messages"][-1].tool_calls  # 📝 Get the most recent tool calls

    return {
        "messages": [
            ToolMessage(
                content=f"Error: {repr(error)}\n please fix your mistakes.",  # ⚡ Show the error details
                tool_call_id=tc["id"],  # 🔗 Link the error to the specific tool call
            )
            for tc in tool_calls  # 🔄 Loop over all tool calls that might have failed
        ]
    }
```

### 🔍 **Explanation (Line by Line):**  
- `state.get("error")`: Retrieves the error from the app's current state.  
- `state["messages"][-1].tool_calls`: Fetches the latest message's tool calls (to identify which tool caused the error).  
- `ToolMessage(...)`: Creates a readable error message linked to the specific tool call.  

### ✅ **Example Output:**  
```
Error: ValueError('Invalid destination') 
Please fix your mistakes.
```

---

### 2️⃣ **`create_tool_node_with_fallback` – Adding Error Recovery**  
This function ensures that if a tool fails, it automatically tries to handle the error instead of stopping everything.  

### 💡 **Why is it needed?**  
Apps that interact with external tools must handle unexpected issues. This function **adds fallback behavior** (a plan B) for tools.  

### 💻 **Code Example & Explanation:**
```python
from langchain_core.runnables import RunnableLambda
from langgraph.prebuilt import ToolNode

def create_tool_node_with_fallback(tools: list) -> dict:
    return ToolNode(tools).with_fallbacks(
        [RunnableLambda(handle_tool_error)],  # 💥 If a tool fails, handle_tool_error runs
        exception_key="error"  # 🔑 Specifies what kind of exception to look for
    )
```

### 🔍 **Explanation (Line by Line):**  
- `ToolNode(tools)`: Creates a **tool node** that can execute a list of tools.  
- `.with_fallbacks(...)`: If any tool raises an error, it triggers the **fallback function** (`handle_tool_error`).  
- `exception_key="error"`: Specifies the **error key** to track issues.  

### 🌟 **Example Use Case:**  
When booking a flight, if the booking tool fails, the bot will return a clear error message instead of crashing, allowing users to retry or correct input.

---

### 3️⃣ **`_print_event` – Debugging the Chat Flow**  
This helper function **prints the chat’s state** and **messages** during debugging.  

### 💡 **Why is it needed?**  
When building chat applications, **developers need to see** what the system is currently processing.  

### 💻 **Code Example & Explanation:**
```python
def _print_event(event: dict, _printed: set, max_length=1500):
    current_state = event.get("dialog_state")
    if current_state:
        print("Currently in: ", current_state[-1])  # 📢 Show current dialog state

    message = event.get("messages")
    if message:
        if isinstance(message, list):
            message = message[-1]  # 📝 Get the latest message
        if message.id not in _printed:
            msg_repr = message.pretty_repr(html=True)  # 🎨 Make the message readable
            if len(msg_repr) > max_length:  # ✂️ Truncate if too long
                msg_repr = msg_repr[:max_length] + " ... (truncated)"
            print(msg_repr)
            _printed.add(message.id)  # 🏷️ Mark message as printed to avoid duplicates
```

### 🔍 **Explanation (Line by Line):**  
- `event.get("dialog_state")`: Shows where we are in the conversation flow.  
- `message.pretty_repr(html=True)`: Converts messages into a **pretty HTML format** for easier debugging.  
- **Truncation Logic:** Ensures logs aren’t too long to overwhelm the console.  

### 🛠️ **Example Output:**
```
Currently in: booking_state
User: "I want to book a trip to Paris."
Bot: "Checking available trips to Paris... Please wait."
```

---

## 🌈 **Summary of Key Concepts**  
| 🔑 **Function**                  | 💡 **Purpose**                               | 🌍 **Real-World Example**                     |
|-------------------------------|------------------------------------------|------------------------------------------|
| `handle_tool_error`           | Display user-friendly errors              | Shows clear messages when bookings fail. |
| `create_tool_node_with_fallback` | Adds fallback if tool fails               | Auto-retries booking or shows error gracefully. |
| `_print_event`                | Debugging by printing state & messages    | Shows which part of the chat is active and what’s being processed. |

---

## 🚀 **Final Thoughts**  
These utility functions are **essential** when working with **chatbots**, **AI assistants**, or **automated workflows** because they:  
✅ Help users understand issues.  
✅ Make debugging easier for developers.  
✅ Prevent the system from crashing during unexpected failures.  

✨ By mastering such patterns, you'll be able to build **robust**, **user-friendly**, and **maintainable** applications.  

---

Let me know if you'd like further examples or how to integrate these functions into a complete chatbot! 😊