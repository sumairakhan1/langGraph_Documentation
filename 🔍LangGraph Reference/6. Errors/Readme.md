# 🧩 Understanding Custom Errors in Python Graph Execution

When working with **graph-based execution models**, such as **AI pipelines, workflow automation, or distributed systems**, it's essential to handle errors properly to avoid infinite loops, invalid updates, or execution failures. In this guide, we'll break down **custom exceptions** used in a **graph execution system** and explain their **real-world applications, code examples, and alternative implementations**.

---

## 📌 **What Are Custom Exceptions in Python?**
Custom exceptions in Python are **user-defined error classes** that inherit from built-in exception classes like `Exception` or `RecursionError`. They allow developers to create more meaningful error messages specific to their applications.

### ✅ **Why Use Custom Exceptions?**
- **Better Debugging:** Provides clear and specific error messages.
- **Control Execution Flow:** Stops invalid processes from continuing.
- **Improve Code Readability:** Makes it easier to understand error handling.

---

## 🏗 **Exploring Graph Execution Errors**
Let's break down the **custom exceptions** used in the **graph execution system**.

### 🔁 **1. GraphRecursionError (Infinite Loop Prevention)**
#### **📌 What It Does?**
- Raised when the graph execution reaches the **maximum recursion limit**.
- Prevents **infinite loops** in recursive graph structures.
- You can increase the recursion limit in the configuration.

#### **🛠 Real-World Example**
- **Chatbots & AI Pipelines:** If a chatbot keeps generating responses without stopping, it can hit a recursion limit.
- **Workflow Automation:** If a task keeps retrying indefinitely, this error prevents the system from crashing.

#### **📝 Code Example**
```python
class GraphRecursionError(RecursionError):
    """Raised when the graph has exhausted the maximum number of steps."""
    pass

# Simulating a recursive graph execution
def execute_graph(steps, limit=1000):
    if steps > limit:
        raise GraphRecursionError("Graph execution exceeded recursion limit!")
    print(f"Executing step {steps}")
    execute_graph(steps + 1, limit)  # Recursive call

# Running with a lower recursion limit
try:
    execute_graph(1, limit=5)
except GraphRecursionError as e:
    print(f"Error: {e}")
```
#### **🔍 Explanation**
1. We **define a custom exception** `GraphRecursionError` that extends `RecursionError`.
2. The `execute_graph` function **recursively executes steps**.
3. If `steps > limit`, it **raises the error**.
4. We **catch the error** in a `try-except` block and print a helpful message.

#### **🛠 Alternative Approaches**
1. **Use an Iterative Loop Instead of Recursion**  
   ```python
   def execute_graph_iterative(limit=1000):
       for steps in range(limit + 1):
           print(f"Executing step {steps}")
   execute_graph_iterative(5)
   ```
2. **Use a Stack to Simulate Recursion**  
   ```python
   def execute_graph_stack(limit=1000):
       stack = [0]
       while stack:
           steps = stack.pop()
           print(f"Executing step {steps}")
           if steps < limit:
               stack.append(steps + 1)
   execute_graph_stack(5)
   ```
3. **Set a Recursion Limit Dynamically**
   ```python
   import sys
   sys.setrecursionlimit(2000)  # Increase recursion limit
   ```

---

### 🚫 **2. InvalidUpdateError (Preventing Wrong Updates)**
#### **📌 What It Does?**
- Raised when **invalid data** is used to update a channel or a node in the graph.
- Prevents **corrupted updates** that might break execution.

#### **🛠 Real-World Example**
- **Streaming Services:** If an update contains invalid metadata for a video stream.
- **Machine Learning Pipelines:** If a model receives inconsistent training data.

#### **📝 Code Example**
```python
class InvalidUpdateError(Exception):
    """Raised when attempting to update a channel with an invalid set of updates."""
    pass

def update_node(data):
    if not isinstance(data, dict) or "id" not in data:
        raise InvalidUpdateError("Invalid update: Data must be a dictionary with an 'id' field.")
    print(f"Node {data['id']} updated successfully!")

try:
    update_node({"name": "AI Model"})  # Missing "id"
except InvalidUpdateError as e:
    print(f"Error: {e}")
```

---

### 🔄 **3. GraphInterrupt & NodeInterrupt (Stopping Execution Midway)**
#### **📌 What It Does?**
- `GraphInterrupt`: Raised when **a subgraph is interrupted** and **handled by the root graph**.
- `NodeInterrupt`: Raised when **a specific node** in the graph execution needs to stop.

#### **🛠 Real-World Example**
- **Smart Home Systems:** If a fire alarm triggers, it **interrupts** ongoing operations.
- **Industrial Automation:** If a machine detects an issue, it **stops** the affected component while letting others run.

#### **📝 Code Example**
```python
class GraphInterrupt(Exception):
    """Raised when a subgraph is interrupted."""
    pass

class NodeInterrupt(GraphInterrupt):
    """Raised by a node to interrupt execution."""
    pass

def process_node(task):
    if task == "stop":
        raise NodeInterrupt("Node execution stopped due to an error.")
    print(f"Processing node task: {task}")

try:
    process_node("stop")
except NodeInterrupt as e:
    print(f"Execution interrupted: {e}")
```

---

### 📭 **4. EmptyInputError (Handling Missing Data)**
#### **📌 What It Does?**
- Raised when **no input is received** for a graph node.
- Prevents execution when required data is missing.

#### **🛠 Real-World Example**
- **Form Validation:** If a user submits a form without required fields.
- **API Calls:** If an API endpoint receives an empty request.

#### **📝 Code Example**
```python
class EmptyInputError(Exception):
    """Raised when graph receives an empty input."""
    pass

def process_input(data):
    if not data:
        raise EmptyInputError("Input cannot be empty.")
    print(f"Processing input: {data}")

try:
    process_input("")  # Empty input
except EmptyInputError as e:
    print(f"Error: {e}")
```

---

### 🔍 **5. TaskNotFound (Handling Missing Tasks)**
#### **📌 What It Does?**
- Raised when **a task is missing** in a distributed system.
- Ensures proper task scheduling.

#### **🛠 Real-World Example**
- **Cloud Task Management:** If a scheduled job cannot be found.
- **Microservices:** If a request is sent to a missing service.

#### **📝 Code Example**
```python
class TaskNotFound(Exception):
    """Raised when the executor is unable to find a task."""
    pass

tasks = {"task1": "Process Data"}

def execute_task(task_id):
    if task_id not in tasks:
        raise TaskNotFound(f"Task '{task_id}' not found.")
    print(f"Executing {tasks[task_id]}")

try:
    execute_task("task2")  # Task not available
except TaskNotFound as e:
    print(f"Error: {e}")
```

---

## 🎯 **Key Takeaways**
| Exception Name      | Purpose |
|--------------------|---------|
| **GraphRecursionError** | Prevents infinite loops in recursive graph execution. |
| **InvalidUpdateError** | Stops invalid updates to graph nodes. |
| **GraphInterrupt / NodeInterrupt** | Stops execution of a graph or a specific node. |
| **EmptyInputError** | Ensures required input is provided. |
| **TaskNotFound** | Handles missing tasks in execution. |

---

## 🎯 **Final Thoughts**
By defining **custom exceptions**, we make **graph-based execution systems** more **robust, scalable, and debuggable**. These techniques apply to **chatbots, workflow automation, distributed computing, and AI pipelines**.

Would you like more **alternative implementations** or **real-world case studies**? 😊🚀