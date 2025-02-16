# 🚀 **Understanding LangGraph Functional API & `entrypoint` Decorator**

The **LangGraph Functional API** provides a way to define workflows using the `entrypoint` decorator. This is useful when designing workflows that require long-term memory, runtime configuration, or checkpointing.

## 🔥 **What is the `entrypoint` Decorator?**
The `entrypoint` decorator is used to define a **workflow function** in LangGraph. This function:
- Takes a **single input parameter** (can be of any type, typically a dictionary for multiple parameters).
- Supports **state management** through checkpointers.
- Can be **interrupted and resumed** without re-executing previous steps.

---

## 🎯 **Why Use the `entrypoint` Decorator?**
✔️ Enables **workflow management** with state persistence.  
✔️ Supports **interruptions and human reviews** during execution.  
✔️ Allows **access to previous return values**, making workflows smarter.  

---

## 🌍 **Real-World Use Case**
Imagine you're building an **AI-powered content review system** that generates essays and allows human reviewers to provide feedback before finalizing the content. The `entrypoint` decorator helps manage this workflow efficiently.

---

## 🏗 **Key Features of the Functional API**
| Parameter    | Description |
|-------------|------------|
| `store`     | A memory store for long-term data storage. |
| `writer`    | A tool to write data to a stream (useful for logs). |
| `config`    | Holds runtime configurations (e.g., thread management). |
| `previous`  | Retrieves the **last return value** for the given thread (if a checkpointer is used). |

---

## 🚀 **Step-by-Step Code Explanation**
Let’s break down an example of an **AI essay review workflow** using `entrypoint`.

### 📌 **Code: Defining the Workflow**
```python
import time
from langgraph.func import entrypoint, task
from langgraph.types import interrupt, Command
from langgraph.checkpoint.memory import MemorySaver

# Step 1️⃣: Define a task for generating an essay
@task
def compose_essay(topic: str) -> str:
    time.sleep(1.0)  # Simulate a slow operation
    return f"An essay about {topic}"

# Step 2️⃣: Define the main workflow using @entrypoint
@entrypoint(checkpointer=MemorySaver())
def review_workflow(topic: str) -> dict:
    """
    Manages the workflow for essay generation and review.

    1. Generates an essay.
    2. Interrupts the workflow for a human review.
    
    Returns:
        dict: Contains the generated essay and human review.
    """
    # Generate the essay
    essay_future = compose_essay(topic)
    essay = essay_future.result()

    # Interrupt the workflow and wait for human review
    human_review = interrupt({
        "question": "Please provide a review",
        "essay": essay
    })

    return {
        "essay": essay,
        "review": human_review,
    }

# Step 3️⃣: Define Configuration and Stream Execution
config = {
    "configurable": {
        "thread_id": "some_thread"
    }
}

topic = "cats"

# Start the workflow
for result in review_workflow.stream(topic, config):
    print(result)

# Provide human feedback
human_review = "This essay is great."

# Resume workflow with review feedback
for result in review_workflow.stream(Command(resume=human_review), config):
    print(result)
```

### 📖 **Code Explanation**
- `@task` → Defines an **async task** `compose_essay(topic)` to generate content.
- `@entrypoint(checkpointer=MemorySaver())` → Defines a **workflow function** that:
  - Calls the `compose_essay` function.
  - **Interrupts** execution for a human review.
  - **Resumes execution** once feedback is provided.
- **`config` dictionary** → Stores runtime settings like `thread_id`.
- **`stream()` function** → Executes and streams the workflow in steps.

---

## ⏳ **Handling Previous Return Values**
When a checkpointer is used, we can **retrieve previous return values** in a workflow.

### 📌 **Example: Storing Previous Values**
```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def my_workflow(input_data: str, previous: str = None) -> str:
    return "world"

config = {
    "configurable": {
        "thread_id": "some_thread"
    }
}

# Initial invocation
my_workflow.invoke("hello")
```
✅ **Purpose**:
- Uses `previous` to store the last return value.
- If `previous` exists, it gets reused in the next function call.

---

## 📌 **Using `entrypoint.final` to Save Different Checkpoint Values**
If you need to **return one value but save another** for future executions, use `entrypoint.final`.

### **Example: Returning a Value While Storing Another**
```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def my_workflow(number: int, *, previous: int = None) -> entrypoint.final[int, int]:
    previous = previous or 0
    # Return previous value but save 2 * number for next call
    return entrypoint.final(value=previous, save=2 * number)

config = {
    "configurable": {
        "thread_id": "some_thread"
    }
}

print(my_workflow.invoke(3, config))  # Output: 0 (previous was None)
print(my_workflow.invoke(1, config))  # Output: 6 (previous was 3 * 2)
```
✅ **Purpose**:
- Returns the **previous value**.
- Saves a **new value** (`2 * number`) for future calls.

---

## 🛠 **Alternative Examples**
### **1️⃣ Alternative: A Simple Task-Based Workflow**
```python
@task
def double_number(n: int) -> int:
    return n * 2

@entrypoint()
def process_number(n: int) -> int:
    return double_number(n).result()

print(process_number.invoke(4))  # Output: 8
```

---

### **2️⃣ Alternative: Using `entrypoint` with Multiple Inputs**
```python
@entrypoint()
def add_numbers(data: dict) -> int:
    return data["a"] + data["b"]

print(add_numbers.invoke({"a": 5, "b": 10}))  # Output: 15
```

---

### **3️⃣ Alternative: Stateful Counter Using `entrypoint.final`**
```python
@entrypoint(checkpointer=MemorySaver())
def counter(previous: int = 0) -> entrypoint.final[int, int]:
    return entrypoint.final(value=previous, save=previous + 1)

print(counter.invoke())  # Output: 0
print(counter.invoke())  # Output: 1
print(counter.invoke())  # Output: 2
```
✅ **Purpose**:
- Stores an **incrementing counter** across function calls.

---

## 🎯 **Key Takeaways**
🔹 The `entrypoint` decorator **manages workflows** in LangGraph.  
🔹 `checkpointer` allows **stateful processing** across multiple executions.  
🔹 `entrypoint.final` lets you **return one value but store another**.  
🔹 Supports **interruptions and resumptions** (e.g., for human reviews).  

### **🌍 Real-World Applications**
✅ AI-powered **content generation & review systems**.  
✅ Automated **form submissions with user feedback**.  
✅ **Data processing workflows** that require human intervention.  

---
## 🔥 **Final Thoughts**
The **LangGraph Functional API** provides powerful tools to **build robust, stateful workflows** with minimal effort. By leveraging the `entrypoint` decorator, we can create workflows that can **pause, resume, and manage state** effectively.

Would you like more examples tailored to a specific use case? 🚀

---


# 🚀 Functional API with Entrypoint Decorator

The **Functional API** in LangGraph lets you define workflows as Python functions decorated with `@entrypoint`. This API is **beta**, meaning it may change, but it offers a powerful way to build stateful, interruptible workflows. Let’s break it down step by step.

---

## 📘 Overview

- **Entrypoint Decorator:**  
  - Turns a regular function into a workflow entrypoint.  
  - Accepts a single input parameter (or a dictionary for multiple parameters).

- **Injectable Parameters:**  
  Your workflow function can automatically receive extra parameters at runtime:
  - **store:** A key-value store for saving long-term memory.
  - **writer:** A stream writer for custom data output.
  - **config:** Configuration values at runtime.
  - **previous:** The result from the previous run (if a checkpointer is used).

- **State Management:**  
  - The `previous` parameter lets you access data saved from the last invocation.
  - The `entrypoint.final` object allows you to return one value to the caller while saving a different value to the checkpoint.

- **Synchronous and Asynchronous:**  
  - You can decorate both sync and async functions.

---

## 🛠️ Real-World Example: Essay Generation and Review

Imagine a system that **generates an essay** on a given topic and then **pauses** to let a human review the generated essay before continuing. This workflow might be used in an educational tool or content creation platform.

### Example Code: Essay Generation and Review

```python
import time
from langgraph.func import entrypoint, task
from langgraph.types import interrupt, Command
from langgraph.checkpoint.memory import MemorySaver

# 📝 Define a task that composes an essay.
@task
def compose_essay(topic: str) -> str:
    time.sleep(1.0)  # Simulate a slow operation (e.g., content generation)
    return f"An essay about {topic}"

# 🚪 Define the main workflow using the entrypoint decorator.
@entrypoint(checkpointer=MemorySaver())
def review_workflow(topic: str) -> dict:
    """
    This workflow does the following:
    1. Generates an essay using the compose_essay task.
    2. Pauses the workflow with an interrupt for human review.
    3. On resume, it returns both the essay and the review.

    Args:
        topic (str): The subject of the essay.

    Returns:
        dict: Contains the generated essay and the human review.
    """
    # Launch the essay composition task.
    essay_future = compose_essay(topic)
    # Wait for the essay generation to complete.
    essay = essay_future.result()
    
    # Interrupt the workflow to get a human review.
    human_review = interrupt({
        "question": "Please provide a review",
        "essay": essay
    })
    
    # Return the essay and the human review as a dictionary.
    return {
        "essay": essay,
        "review": human_review,
    }

# 🔧 Example configuration for the workflow.
config = {
    "configurable": {
        "thread_id": "some_thread"  # Unique identifier for saving state.
    }
}

# ✏️ Run the workflow to generate the essay and wait for review.
topic = "cats"
for result in review_workflow.stream(topic, config):
    print(result)

# 💬 Later, provide the human review to resume the workflow.
human_review = "This essay is great."
for result in review_workflow.stream(Command(resume=human_review), config):
    print(result)
```

### Code Explanation

- **Import Statements:**  
  - `import time` is used to simulate delays.  
  - The `langgraph` imports bring in the decorators (`entrypoint`, `task`), types (`interrupt`, `Command`), and a simple in-memory checkpointer (`MemorySaver`).

- **Task Definition (`compose_essay`):**  
  - `@task` decorator marks this function as a workflow task.
  - `time.sleep(1.0)` simulates a delay to mimic a slow operation.
  - Returns a string containing the essay content.

- **Workflow Definition (`review_workflow`):**  
  - `@entrypoint(checkpointer=MemorySaver())` marks this function as the main entrypoint for the workflow and enables state saving.
  - The function accepts a single parameter (`topic`) and returns a dictionary.
  - **Inside the function:**
    - **Essay Generation:**  
      - Calls `compose_essay(topic)` and waits for its result.
    - **Interrupt for Review:**  
      - The `interrupt()` function sends a message (with the essay and a review question) that pauses the workflow.
    - **Return Statement:**  
      - Returns a dictionary with the generated essay and the human review.

- **Configuration & Execution:**  
  - The `config` dictionary defines a `thread_id` for state persistence.
  - The first `for` loop starts the workflow and prints intermediate results.
  - After a human review is provided, the second loop resumes the workflow with the review value.

---

## 🔄 Alternative Examples

Here are three more examples to help solidify the concept.

---

### 1️⃣ Alternative Example: Accumulate Sum Workflow

This workflow uses a checkpointer to accumulate a running total.  
It demonstrates how the `previous` parameter retains state between invocations.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def accumulate_sum(value: int, previous: int = 0) -> int:
    """
    Adds the current value to the previous sum and returns the new sum.
    
    Args:
        value (int): The new number to add.
        previous (int, optional): The previous sum (default is 0).
    
    Returns:
        int: The updated sum.
    """
    new_sum = previous + value  # Add the new value to the previous sum.
    return new_sum

# Configuration for state persistence.
config = {"configurable": {"thread_id": "sum_thread"}}

# Initial invocation (previous is 0 by default).
result1 = accumulate_sum.invoke(5, config)
print("Current Sum:", result1)  # Expected output: 5

# Next invocation uses the previous sum.
result2 = accumulate_sum.invoke(10, config)
print("Current Sum:", result2)  # Expected output: 15
```

**Line-by-Line Explanation:**

- **Definition:**  
  - The function `accumulate_sum` accepts a new number and the previous sum.
- **State Update:**  
  - It adds the new number (`value`) to `previous` and returns the updated sum.
- **Configuration & Invocation:**  
  - The same `thread_id` ensures the previous sum is remembered between calls.

---

### 2️⃣ Alternative Example: Async Data Fetch Workflow

This workflow shows how to use an asynchronous task to fetch data, demonstrating async support.

```python
import asyncio
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint, task

@task
async def fetch_data(endpoint: str) -> dict:
    """
    Simulates fetching data asynchronously.
    
    Args:
        endpoint (str): The API endpoint to fetch data from.
    
    Returns:
        dict: A simulated data response.
    """
    await asyncio.sleep(1)  # Simulate network delay.
    return {"data": f"Data from {endpoint}"}

@entrypoint(checkpointer=MemorySaver())
async def data_workflow(endpoint: str) -> dict:
    """
    Asynchronously fetches data and returns it.
    
    Args:
        endpoint (str): The API endpoint.
    
    Returns:
        dict: Contains the fetched data.
    """
    data_future = fetch_data(endpoint)
    data = await data_future  # Await the asynchronous task.
    return {"fetched_data": data}

# Async configuration.
config = {"configurable": {"thread_id": "data_thread"}}

# Run the async workflow.
async def run_async_workflow():
    result = await data_workflow.invoke(endpoint="https://api.example.com/data", config=config)
    print(result)

# Start the async workflow.
asyncio.run(run_async_workflow())
```

**Line-by-Line Explanation:**

- **Async Task (`fetch_data`):**  
  - Marked with `@task` and defined as `async`.  
  - Uses `await asyncio.sleep(1)` to simulate delay.
- **Async Workflow (`data_workflow`):**  
  - Also defined as `async` and uses the checkpointer.
  - Awaits the result of the `fetch_data` task.
- **Execution:**  
  - An async function `run_async_workflow` is defined and executed using `asyncio.run()`.

---

### 3️⃣ Alternative Example: Using entrypoint.final to Separate Return and Checkpoint

This workflow returns a value to the caller while saving a different value in the checkpoint.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def dual_value_workflow(number: int, *, previous: int = None) -> entrypoint.final[int, int]:
    """
    Returns the previous checkpoint value while saving a new calculated value.
    
    Args:
        number (int): The input number.
        previous (int, optional): The previous checkpoint value (default is None).
    
    Returns:
        entrypoint.final: Contains the value to return and the new value to save.
    """
    # Use previous value or default to 0.
    previous = previous or 0
    new_checkpoint = 2 * number  # Calculate a new value to be saved.
    # Return the previous value to the caller, and save the new_checkpoint.
    return entrypoint.final(value=previous, save=new_checkpoint)

# Configuration for state persistence.
config = {"configurable": {"thread_id": "dual_thread"}}

# First invocation: no previous value, so returns 0 and saves 2*3 = 6.
result_first = dual_value_workflow.invoke(3, config)
print("Returned Value:", result_first)

# Second invocation: uses the saved value (6) as previous.
result_second = dual_value_workflow.invoke(1, config)
print("Returned Value:", result_second)
```

**Line-by-Line Explanation:**

- **Function Definition:**  
  - The function accepts a number and an optional `previous` value.
- **Calculation:**  
  - If `previous` is `None`, it defaults to 0.
  - Calculates a new checkpoint value (`2 * number`).
- **Using entrypoint.final:**  
  - `entrypoint.final(value=previous, save=new_checkpoint)` returns the old value to the caller and saves the new value.
- **Invocation:**  
  - The first call returns 0 (as no previous value exists) and saves 6.
  - The second call returns the saved value (6).

---

## 🎯 Key Takeaways

- **Entrypoint Decorator:** Converts a function into a stateful workflow.
- **Injectable Parameters:** Enable additional runtime features like state management and configuration.
- **State Persistence:** With a checkpointer, you can resume workflows using previous state.
- **Flexibility:** Use synchronous or asynchronous functions, and even separate returned values from checkpoint values with `entrypoint.final`.

This powerful API is well-suited for building long-running processes such as data pipelines, human-in-the-loop systems, or any scenario where you need to pause and resume tasks while keeping track of state.

Happy coding! 🚀

---

# 🚀 **Understanding `entrypoint.final` in LangGraph (Deep Explanation for Beginners)**
LangGraph provides a **Functional API** for defining workflows, and `entrypoint.final` is an important part of handling state management efficiently.

This guide will break down:
1. **What is `entrypoint.final`?**
2. **Why is it needed?**
3. **How does it work?**
4. **Real-world use case**
5. **Code example with step-by-step explanation**
6. **Alternative examples for a better understanding**

---

## 📌 **1. What is `entrypoint.final`?**
`entrypoint.final` is a **primitive** (a basic building block) used in LangGraph workflows. It helps **separate**:
- The **value returned to the caller**
- The **value saved to the checkpoint** (for future workflow runs)

💡 **Key Idea:** This allows you to store a value for future use while returning something different to the user.

---

## 📌 **2. Why is `entrypoint.final` needed?**
In workflows, sometimes you need to:
- **Remember previous results** (state management)
- **Avoid redundant computations** (performance optimization)
- **Resume from the last known state** (fault tolerance)

For example, if you're processing a document and saving a progress state, you might want to return a summary to the user but store the entire document for later processing.

---

## 📌 **3. How does `entrypoint.final` work?**
- It **returns one value** to the caller.
- It **saves another value** for the next execution using a **checkpoint**.
- On the next function call, the saved value is available in the `previous` parameter.

---

## 📌 **4. Real-world Use Case**
Imagine an **e-learning platform** where:
- A student attempts a quiz.
- The system keeps track of the highest score.
- The student sees their last attempt, but the system stores the best score.

Using `entrypoint.final`, we can:
- Return the latest attempt’s score.
- Save the best score for future attempts.

---

## 📌 **5. Code Example with Explanation**
```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint
from typing import Any

# ✅ Defining an entrypoint with a memory-based checkpoint
@entrypoint(checkpointer=MemorySaver())
def my_workflow(number: int, *, previous: Any = None) -> entrypoint.final[int, int]:
    """
    A workflow function that saves twice the input number while returning the previous value.

    Args:
        number (int): The current input number.
        previous (Any, optional): The previously saved number. Defaults to None.

    Returns:
        entrypoint.final[int, int]: Returns the previous number and saves double of the current input.
    """
    # If there's no previous value, initialize it to 0
    previous = previous or 0  

    # ✅ Returning the previous value, but saving double the current input for next time
    return entrypoint.final(value=previous, save=2 * number)

# ✅ Defining a configuration with a thread ID
config = {
    "configurable": {
        "thread_id": "1"  # Unique identifier for the workflow session
    }
}

# ✅ First execution (no previous value, so it returns 0)
print(my_workflow.invoke(3, config))  # Output: 0

# ✅ Second execution (previous saved value was 3*2=6)
print(my_workflow.invoke(1, config))  # Output: 6
```

---

### 📖 **Line-by-Line Explanation**
1. **Import required modules**
   ```python
   from langgraph.checkpoint.memory import MemorySaver
   from langgraph.func import entrypoint
   from typing import Any
   ```
   - `MemorySaver`: Stores checkpoint values in memory.
   - `entrypoint`: Used to define workflows.
   - `Any`: Allows flexibility in parameter types.

2. **Define the workflow function**
   ```python
   @entrypoint(checkpointer=MemorySaver())
   ```
   - Uses `@entrypoint` decorator to mark this function as a workflow.
   - `MemorySaver()` ensures state persistence across calls.

3. **Define the function signature**
   ```python
   def my_workflow(number: int, *, previous: Any = None) -> entrypoint.final[int, int]:
   ```
   - `number: int`: The input parameter.
   - `previous: Any = None`: Holds the previous saved value.
   - `entrypoint.final[int, int]`: Specifies return type.
     - First `int` → Value returned to caller.
     - Second `int` → Value saved in the checkpoint.

4. **Initialize `previous` if it's `None`**
   ```python
   previous = previous or 0
   ```
   - If `previous` is `None`, set it to `0`.

5. **Return `entrypoint.final`**
   ```python
   return entrypoint.final(value=previous, save=2 * number)
   ```
   - Returns the **previous value** to the caller.
   - Saves `2 * number` for the next function execution.

6. **Create workflow configuration**
   ```python
   config = {
       "configurable": {
           "thread_id": "1"
       }
   }
   ```
   - Assigns a thread ID for session tracking.

7. **Invoke the workflow**
   ```python
   print(my_workflow.invoke(3, config))  # Output: 0
   print(my_workflow.invoke(1, config))  # Output: 6
   ```
   - First call: `3` is processed, returns `0`, saves `6`.
   - Second call: `1` is processed, returns `6`, saves `2`.

---

## 📌 **6. Alternative Examples**
### ✅ **Example 1: Tracking User Login Attempts**
Tracks the number of times a user logs in.
```python
@entrypoint(checkpointer=MemorySaver())
def login_attempts(username: str, *, previous: int = 0) -> entrypoint.final[int, int]:
    return entrypoint.final(value=previous, save=previous + 1)
```
- Returns the previous count.
- Saves the incremented count.

### ✅ **Example 2: Tracking Total Sales in an E-commerce App**
```python
@entrypoint(checkpointer=MemorySaver())
def total_sales(new_sale: float, *, previous: float = 0.0) -> entrypoint.final[float, float]:
    return entrypoint.final(value=previous, save=previous + new_sale)
```
- Returns previous total sales.
- Adds the new sale amount to the checkpoint.

### ✅ **Example 3: Keeping Track of User Ratings**
```python
@entrypoint(checkpointer=MemorySaver())
def user_rating(new_rating: float, *, previous: float = 5.0) -> entrypoint.final[float, float]:
    updated_rating = (previous + new_rating) / 2  # Average
    return entrypoint.final(value=previous, save=updated_rating)
```
- Returns previous rating.
- Saves the updated rating.

---

## 🎯 **Final Summary**
🔹 **`entrypoint.final` is used to separate returned values from saved values.**  
🔹 **Useful for state management and workflow optimization.**  
🔹 **Real-world use cases: tracking progress, login attempts, cumulative calculations.**  
🔹 **Step-by-step code examples demonstrate how it works in different scenarios.**  

Now, you should have a **strong understanding** of how `entrypoint.final` works! 🚀

---

# 🔑 Decoupling Return and Checkpoint with `final` Dataclass

The `final` dataclass in LangGraph is a powerful tool that lets you **decouple the return value** from the value you save to the checkpoint. This means you can return one result to the caller while persisting a different value for future invocations.

---

## 📘 What Is the `final` Dataclass?

In a stateful workflow, you might want to:

- **Return a result** immediately to the user or another process.
- **Save a different value** in a checkpoint so that the next invocation of the workflow can resume from where it left off.

The `final` dataclass helps you achieve this by having two key attributes:

- **`value`**:  
  The value that will be returned to the caller. It can be any type—even `None`.

- **`save`**:  
  The value that will be stored as the state for the next run (i.e., the checkpoint). This, too, can be any type.

---

## 🚀 Real-World Use Case

Imagine you’re building an **online order processing system**. Every time a new order comes in, you want to:

1. **Return the previous inventory count** to the client (e.g., for display purposes).
2. **Save the updated inventory count** after subtracting the order quantity so that future orders know the current stock.

Using the `final` dataclass, you can separate what the client sees (the previous inventory) from what the system stores (the new inventory count).

---

## 🔧 Code Example: Basic `final` Workflow

Below is a detailed code example with line-by-line explanations:

```python
# Import necessary components.
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

# Define a workflow using the entrypoint decorator with a checkpointer.
@entrypoint(checkpointer=MemorySaver())
def my_workflow(number: int, *, previous: any = None) -> entrypoint.final[int, int]:
    """
    A workflow that demonstrates using `final` to separate the return value
    from the checkpoint value.

    Args:
        number (int): An input number used to calculate a new state.
        previous (Any, optional): The previous checkpoint value. Defaults to None.
    
    Returns:
        entrypoint.final[int, int]: Returns the previous value and saves a new one.
    """
    # If 'previous' is None, default to 0.
    previous = previous or 0
    
    # Calculate the new checkpoint value.
    new_checkpoint = 2 * number  # Multiply the input by 2.
    
    # Return a final object:
    # - value: the value to be returned (previous state)
    # - save: the new checkpoint value for next invocation.
    return entrypoint.final(value=previous, save=new_checkpoint)

# Configuration with a unique thread_id to persist state.
config = {
    "configurable": {
        "thread_id": "1"
    }
}

# Invoke the workflow.
result1 = my_workflow.invoke(3, config)  # Returns 0 because previous was None.
print("Returned Value:", result1)         # Expected output: 0

# Invoke again. Now, previous is 2 * 3 = 6.
result2 = my_workflow.invoke(1, config)  # Returns 6 from the previous invocation.
print("Returned Value:", result2)         # Expected output: 6
```

### Code Breakdown

- **Importing Modules:**
  - `MemorySaver`: A simple in-memory checkpointer for saving state.
  - `entrypoint`: Decorator to convert a function into a stateful workflow.
  
- **Defining `my_workflow`:**
  - **Decorator:** `@entrypoint(checkpointer=MemorySaver())` enables checkpointing.
  - **Parameters:**  
    - `number`: The input used for calculation.  
    - `previous`: Automatically injected state from the last run (if any).
  - **Logic:**  
    - Defaults `previous` to 0 if it’s `None`.
    - Computes a new checkpoint value by multiplying `number` by 2.
  - **Return:**  
    - Uses `entrypoint.final` to return the old checkpoint value (`value`) and save the new value (`save`).

- **Configuration & Invocation:**
  - A configuration dictionary with a `thread_id` ensures state persistence.
  - The first call returns 0 and saves 6. The second call uses the saved state (6).

---

## 🔄 Alternative Examples

To help you grasp the concept further, here are three more examples that illustrate different real-world scenarios.

---

### 1️⃣ Alternative Example: Inventory Management

In an inventory management system, you want to show the current inventory level to a client, but update the inventory by subtracting an order quantity.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def order_workflow(order_qty: int, *, current_stock: int = None) -> entrypoint.final[int, int]:
    """
    Processes an order by subtracting the order quantity from the current stock.
    
    Args:
        order_qty (int): Quantity of items ordered.
        current_stock (int, optional): Current stock level (injected from checkpoint).
    
    Returns:
        entrypoint.final[int, int]: Returns the previous stock and saves the new stock level.
    """
    # If no current stock is available, assume 100 units initially.
    current_stock = current_stock if current_stock is not None else 100
    
    # Calculate new stock by subtracting the order quantity.
    new_stock = current_stock - order_qty
    
    # Return the previous stock level, while saving the updated stock level.
    return entrypoint.final(value=current_stock, save=new_stock)

# Configuration for inventory workflow.
config_inventory = {"configurable": {"thread_id": "inventory_1"}}

# Process an order of 10 units.
prev_stock = order_workflow.invoke(10, config_inventory)
print("Previous Stock Level:", prev_stock)  # Expected: 100

# Process another order of 5 units.
prev_stock = order_workflow.invoke(5, config_inventory)
print("Previous Stock Level:", prev_stock)  # Expected: 90 (because 100-10 = 90)
```

**Explanation:**

- **Purpose:**  
  Process an order while maintaining and updating the inventory.
- **Key Steps:**  
  - If no previous stock is set, default to 100.
  - Subtract the order quantity from the current stock.
  - Return the old stock level and save the new one.

---

### 2️⃣ Alternative Example: User Score Tracking

Imagine a game where a user's score is updated with each action. You want to return the user's current score before updating it.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def score_workflow(points: int, *, current_score: int = None) -> entrypoint.final[int, int]:
    """
    Updates the user's score by adding new points.
    
    Args:
        points (int): Points earned in the current action.
        current_score (int, optional): The current score from previous checkpoint.
    
    Returns:
        entrypoint.final[int, int]: Returns the previous score and saves the updated score.
    """
    # Default current score to 0 if not provided.
    current_score = current_score or 0
    
    # Calculate new score.
    new_score = current_score + points
    
    # Return the previous score and save the new score.
    return entrypoint.final(value=current_score, save=new_score)

# Configuration for the score workflow.
config_score = {"configurable": {"thread_id": "score_1"}}

# First action: add 15 points.
prev_score = score_workflow.invoke(15, config_score)
print("Previous Score:", prev_score)  # Expected: 0

# Second action: add 10 points.
prev_score = score_workflow.invoke(10, config_score)
print("Previous Score:", prev_score)  # Expected: 15
```

**Explanation:**

- **Purpose:**  
  Track and update a user's score over time.
- **Key Steps:**  
  - If the current score isn’t set, default to 0.
  - Add the new points to the current score.
  - Return the old score and save the updated one.

---

### 3️⃣ Alternative Example: Temperature Logging

Consider a system that logs temperature readings. You might want to display the last recorded temperature but save a new average for future reference.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.func import entrypoint

@entrypoint(checkpointer=MemorySaver())
def temperature_workflow(new_reading: float, *, last_avg: float = None) -> entrypoint.final[float, float]:
    """
    Updates the running average temperature with the new reading.
    
    Args:
        new_reading (float): The latest temperature reading.
        last_avg (float, optional): The last average temperature from the checkpoint.
    
    Returns:
        entrypoint.final[float, float]: Returns the previous average and saves the new average.
    """
    # Default last average to the new reading if not provided.
    last_avg = last_avg if last_avg is not None else new_reading
    
    # Compute a new average (for simplicity, take a weighted average).
    new_avg = (last_avg + new_reading) / 2
    
    # Return the previous average temperature and save the new average.
    return entrypoint.final(value=last_avg, save=new_avg)

# Configuration for temperature logging.
config_temp = {"configurable": {"thread_id": "temp_1"}}

# First reading.
prev_avg = temperature_workflow.invoke(22.0, config_temp)
print("Previous Average Temperature:", prev_avg)  # Expected: 22.0

# Second reading.
prev_avg = temperature_workflow.invoke(24.0, config_temp)
print("Previous Average Temperature:", prev_avg)  # Expected: 22.0 (and new average saved is 23.0)
```

**Explanation:**

- **Purpose:**  
  Log temperature readings while maintaining a running average.
- **Key Steps:**  
  - Initialize the average if not present.
  - Calculate the new average using the previous average and new reading.
  - Return the old average and save the new average for future use.

---

## 🎯 Key Takeaways

- **`final` Dataclass:**  
  - Enables decoupling the return value (what the caller sees) from the checkpoint value (state persisted for the next run).
- **Two Key Attributes:**
  - **`value`**: The immediate result returned to the user.
  - **`save`**: The state saved for subsequent invocations.
- **Real-World Applications:**  
  - Inventory management, user score tracking, temperature logging, etc.
- **Flexibility:**  
  - Use in both synchronous and asynchronous workflows.

By leveraging the `final` dataclass, you can design workflows that are both user-friendly and robust, keeping state separate from immediate outputs. This separation is essential in building long-running, stateful systems where different data is needed at different stages of execution.

Happy coding! 🚀

---


# 🚀 Understanding the `@task` Decorator in LangGraph

LangGraph provides a `@task` decorator that helps define and execute tasks, either synchronously or asynchronously. This is particularly useful in workflows where parallel execution and retry policies are needed. 

Let’s break it down step by step in an easy-to-understand way.

---

## 🧐 What is the `@task` Decorator?
The `@task` decorator in LangGraph is used to define a task that can be executed as part of a workflow. It supports:
- **Synchronous functions** (regular Python functions).
- **Asynchronous functions** (`async def` functions, requires Python 3.11 or higher).
- **Automatic parallel execution** by returning a **future** (which allows the function to run concurrently).

### 🔹 Key Features:
✅ Supports both **sync** and **async** functions.  
✅ Can **automatically retry** failed tasks if a retry policy is provided.  
✅ Works **only inside** an `entrypoint` or `StateGraph`.  
✅ **Parallel execution** using futures.  

---

## 🔥 Real-World Use Case
Imagine you are building a **data processing pipeline** that processes multiple numbers simultaneously. Instead of running them one by one (which is slow), you can **parallelize** the execution using `@task`, making the pipeline faster.

### Example Scenario:  
You need to process a **large list of numbers** by adding 1 to each number **concurrently**. Instead of iterating one by one, you can process them **in parallel** using LangGraph tasks.

---

## 📌 Synchronous Task Example

```python
from langgraph.func import entrypoint, task

# Define a simple task that adds 1 to a number
@task
def add_one(a: int) -> int:
    return a + 1

# Define an entrypoint to process a list of numbers
@entrypoint()
def process_numbers(numbers: list[int]) -> list[int]:
    futures = [add_one(n) for n in numbers]  # Call add_one in parallel
    results = [f.result() for f in futures]  # Get results from futures
    return results

# Call the function
print(process_numbers.invoke([1, 2, 3]))  # Output: [2, 3, 4]
```

### 📝 Explanation:
1. **`@task` decorator**: Turns `add_one` into a LangGraph task.
2. **`entrypoint()` decorator**: Defines the main workflow.
3. **Parallel execution**: `futures = [add_one(n) for n in numbers]` creates **futures** (which will execute tasks in parallel).
4. **Results retrieval**: `f.result()` fetches the computed values.

---

## ⚡ Asynchronous Task Example
Now, let's look at the **async version** of the above example.

```python
import asyncio
from langgraph.func import entrypoint, task

# Define an async task
@task
async def add_one(a: int) -> int:
    return a + 1

# Define an async entrypoint to process numbers
@entrypoint()
async def process_numbers(numbers: list[int]) -> list[int]:
    futures = [add_one(n) for n in numbers]  # Create futures
    return await asyncio.gather(*futures)   # Await all results

# Run the function asynchronously
asyncio.run(process_numbers.invoke([1, 2, 3]))  # Output: [2, 3, 4]
```

### 📝 Explanation:
1. **`@task` on `async def` function**: Allows asynchronous execution.
2. **`asyncio.gather(*futures)`**: Runs all tasks **in parallel**.
3. **`await process_numbers.invoke([...])`**: Ensures that we wait for results.

---

## 🔄 Adding a Retry Policy
Sometimes tasks **fail due to temporary issues** (e.g., network failures). LangGraph allows setting a **retry policy**.

```python
from langgraph.func import entrypoint, task, RetryPolicy

# Define a retry policy
retry_policy = RetryPolicy(max_attempts=3)

# Task with retry
@task(retry=retry_policy)
def fetch_data() -> str:
    print("Fetching data...")
    # Simulating a failure 50% of the time
    import random
    if random.random() < 0.5:
        raise Exception("Temporary Error")
    return "Data Fetched"

# Entrypoint to call the task
@entrypoint()
def workflow() -> str:
    return fetch_data()

# Run the workflow
print(workflow.invoke())  
```

### 📝 Explanation:
1. **Defines a retry policy**: `max_attempts=3` means it will retry **up to 3 times**.
2. **Simulates failure**: The function randomly raises an exception.
3. **Automatic retries**: If the task fails, LangGraph will retry it.

---

## 🏆 Alternative Examples for Better Understanding

### 🛠️ **Example 1: File Processing in Parallel**
Process multiple files **simultaneously**.

```python
@task
def process_file(file_name: str) -> str:
    return f"Processed {file_name}"

@entrypoint()
def process_all(files: list[str]) -> list[str]:
    futures = [process_file(f) for f in files]
    return [f.result() for f in futures]

print(process_all.invoke(["file1.txt", "file2.txt"]))
```

---

### 📡 **Example 2: Sending Multiple API Requests**
Make multiple API calls in **parallel**.

```python
import requests

@task
def fetch_data(url: str) -> dict:
    response = requests.get(url)
    return response.json()

@entrypoint()
def fetch_all(urls: list[str]) -> list[dict]:
    futures = [fetch_data(url) for url in urls]
    return [f.result() for f in futures]

urls = ["https://api.example.com/data1", "https://api.example.com/data2"]
print(fetch_all.invoke(urls))
```

---

### 🏎️ **Example 3: Running Heavy Computations Concurrently**
Run **multiple** computations in parallel.

```python
@task
def compute(x: int) -> int:
    return x * x

@entrypoint()
def run_computations(numbers: list[int]) -> list[int]:
    futures = [compute(n) for n in numbers]
    return [f.result() for f in futures]

print(run_computations.invoke([1, 2, 3, 4]))  # Output: [1, 4, 9, 16]
```

---

## 🎯 Key Takeaways
✅ The `@task` decorator defines functions that **run in parallel**.  
✅ **Supports both sync and async** functions.  
✅ **Retry failed tasks** automatically with `RetryPolicy`.  
✅ Tasks **must be called from an entrypoint** or `StateGraph`.  
✅ Ideal for **parallel processing**, **API calls**, **file processing**, and more.  

Would you like me to go deeper into any specific part? 😊

---

# 🚀 Task Decorator: Parallelizing Workflows in LangGraph

The **task decorator** in LangGraph is a powerful tool that lets you transform regular functions (both synchronous and asynchronous) into **tasks** that can be executed concurrently. This is especially useful when you need to parallelize operations in a workflow.

---

## 📘 What Is the Task Decorator?

The `@task` decorator converts a function into a task that returns a **future** when called. This future represents the eventual result of the task, enabling you to run multiple tasks in parallel and wait for their results later. Here are some key points:

- **Parallel Execution:** Calling a task returns a future so that multiple tasks can run concurrently.
- **Sync & Async Support:** It supports both synchronous and asynchronous functions.
- **Retry Policies:** You can specify a retry policy to handle transient failures.
- **Serialization:** If using a checkpointer, inputs and outputs must be serializable.
- **Usage Scope:** Tasks can only be called within an entrypoint or a StateGraph.

---

## 🎯 Real-World Example: Web Scraping

Imagine you’re building a **web scraping** system where you need to fetch data from multiple URLs simultaneously. Each URL fetch can be implemented as a task so that your system doesn’t wait for one URL to complete before starting the next.

---

## 📝 Code Example: Synchronous Task

Below is an example of a synchronous task that adds one to each number in a list.

```python
from langgraph.func import entrypoint, task

# Define a synchronous task to add one to a number.
@task
def add_one(a: int) -> int:
    return a + 1

# Define an entrypoint workflow that processes a list of numbers.
@entrypoint()
def process_numbers(numbers: list[int]) -> list[int]:
    # Call the add_one task for each number; this returns a future.
    futures = [add_one(n) for n in numbers]
    
    # Wait for each future to complete and collect the results.
    results = [f.result() for f in futures]
    return results

# Invoke the workflow with a list of numbers.
result = process_numbers.invoke([1, 2, 3])  # Expected output: [2, 3, 4]
print("Synchronous Task Result:", result)
```

### Code Explanation

- **Importing Decorators:**  
  `from langgraph.func import entrypoint, task` imports the necessary decorators.
  
- **Task Definition (`add_one`):**  
  - `@task` marks the function as a task.
  - `def add_one(a: int) -> int:` defines a simple function that adds one to the input.
  - `return a + 1` computes and returns the result.
  
- **Workflow Definition (`process_numbers`):**  
  - `@entrypoint()` marks the function as the workflow’s starting point.
  - `futures = [add_one(n) for n in numbers]` calls `add_one` for each number, returning a list of futures.
  - `results = [f.result() for f in futures]` waits for each task to finish and collects the results.
  
- **Invocation:**  
  `process_numbers.invoke([1, 2, 3])` starts the workflow, and the result is printed.

---

## 🔄 Code Example: Asynchronous Task

For asynchronous functions (available in Python 3.11+), tasks work similarly. Here’s an async version:

```python
import asyncio
from langgraph.func import entrypoint, task

# Define an asynchronous task to add one to a number.
@task
async def add_one(a: int) -> int:
    return a + 1

# Define an asynchronous workflow entrypoint.
@entrypoint()
async def process_numbers(numbers: list[int]) -> list[int]:
    # Create asynchronous tasks for each number.
    futures = [add_one(n) for n in numbers]
    
    # Use asyncio.gather to wait for all tasks concurrently.
    results = await asyncio.gather(*futures)
    return results

# Async function to run the workflow.
async def main():
    result = await process_numbers.ainvoke([1, 2, 3])  # Expected output: [2, 3, 4]
    print("Asynchronous Task Result:", result)

# Run the asynchronous workflow.
asyncio.run(main())
```

### Code Explanation

- **Async Imports:**  
  `import asyncio` is used for managing asynchronous execution.
  
- **Async Task Definition (`add_one`):**  
  - `@task` marks the function as a task.
  - `async def add_one(a: int) -> int:` defines an asynchronous version of the function.
  
- **Async Workflow (`process_numbers`):**  
  - `@entrypoint()` marks the workflow’s entrypoint.
  - Tasks are started concurrently, and `asyncio.gather(*futures)` waits for all tasks to complete.
  
- **Running the Workflow:**  
  The `main` function awaits the workflow’s results, and `asyncio.run(main())` runs the event loop.

---

## 🔄 Alternative Examples

To further solidify your understanding, here are three additional examples.

---

### 1️⃣ Multiplication Task

A task that multiplies a number by 2 and processes a list of numbers concurrently.

```python
from langgraph.func import entrypoint, task

@task
def multiply_by_two(n: int) -> int:
    return n * 2

@entrypoint()
def process_numbers(numbers: list[int]) -> list[int]:
    futures = [multiply_by_two(n) for n in numbers]
    results = [f.result() for f in futures]
    return results

result = process_numbers.invoke([2, 4, 6])
print("Multiplication Task Result:", result)  # Expected: [4, 8, 12]
```

**Explanation:**
- **`multiply_by_two` Task:** Multiplies the input by 2.
- **Workflow:** Processes a list of numbers concurrently, collecting and returning the results.

---

### 2️⃣ String Concatenation Task

A task that appends an exclamation mark to each string.

```python
from langgraph.func import entrypoint, task

@task
def append_exclamation(word: str) -> str:
    return word + "!"

@entrypoint()
def process_words(words: list[str]) -> list[str]:
    futures = [append_exclamation(word) for word in words]
    results = [f.result() for f in futures]
    return results

result = process_words.invoke(["hello", "world"])
print("String Task Result:", result)  # Expected: ["hello!", "world!"]
```

**Explanation:**
- **`append_exclamation` Task:** Adds an exclamation mark to the input word.
- **Workflow:** Applies the task to each word concurrently and returns the modified strings.

---

### 3️⃣ File Processing Task

A task that reverses each line of text from a file.

```python
from langgraph.func import entrypoint, task

@task
def reverse_line(line: str) -> str:
    return line[::-1]

@entrypoint()
def process_file(lines: list[str]) -> list[str]:
    futures = [reverse_line(line) for line in lines]
    results = [f.result() for f in futures]
    return results

sample_lines = ["First line", "Second line", "Third line"]
result = process_file.invoke(sample_lines)
print("File Processing Task Result:", result)
```

**Explanation:**
- **`reverse_line` Task:** Reverses the input string.
- **Workflow:** Processes each line concurrently and returns the reversed lines.

---

## 🎯 Key Takeaways

- **@task Decorator:**  
  - Converts functions into tasks that return a future.
  - Supports both synchronous and asynchronous functions.
  
- **Parallelism:**  
  - Calling a task returns a future, enabling parallel execution.
  
- **Real-World Usage:**  
  - Ideal for web scraping, parallel data processing, and any scenario that benefits from concurrent execution.
  
- **Additional Features:**  
  - Supports retry policies for handling failures.
  - Ensures serializability when using checkpointing.

By using the task decorator, you can build highly parallel and efficient workflows in LangGraph, simplifying the process of concurrent execution and state management.

Happy coding! 🚀