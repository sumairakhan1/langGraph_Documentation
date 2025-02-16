# 🧠 Understanding Reducers in LangGraph  
Reducers are essential in **LangGraph** as they define how **state updates** are applied. Each **key** in the state has its own independent **reducer function**, controlling how values change when a node updates the state.

If no reducer function is provided, the **default behavior** is to override the key with the new value.

---

## 🔹 What is a Reducer?  
A **reducer** is a function that determines how new updates from **nodes** are applied to the existing state.  

### 🏗 Structure of Reducers  
1. **Default Reducer:** Overwrites the existing value.  
2. **Custom Reducer:** Allows different ways to merge or update values instead of just replacing them.

---

## 🏆 1. Default Reducer  
If no reducer is specified, the default behavior is to **replace** the value of a key.

### 💡 Example A: Default Reducer  

```python
from typing_extensions import TypedDict

class State(TypedDict):
    foo: int
    bar: list[str]  # This will be replaced entirely by the new value

# Initial State
state = {"foo": 1, "bar": ["hi"]}

# First Node returns an update
update_1 = {"foo": 2}

# Applying the update (foo is replaced)
state.update(update_1)
print(state)  
# Output: {'foo': 2, 'bar': ['hi']}

# Second Node updates "bar"
update_2 = {"bar": ["bye"]}
state.update(update_2)
print(state)  
# Output: {'foo': 2, 'bar': ['bye']} (bar replaced completely)
```

### 🛠 Explanation  
- `foo` changes from `1` to `2` when updated.  
- `bar` was `["hi"]` but gets **replaced** entirely with `["bye"]`.  

### 🌍 Real-World Example:  
Imagine a **shopping cart system** where the last selected items always override previous selections.  
- If a user picks **"Apple"**, the state is `{"cart": ["Apple"]}`.  
- If they later pick **"Banana"**, the state becomes `{"cart": ["Banana"]}` (not `["Apple", "Banana"]`).

---

## 🏆 2. Using a Custom Reducer (Appending Instead of Replacing)  
A **custom reducer** can define how values should be updated. Instead of replacing, we can **combine** old and new values.

### 💡 Example B: Using `operator.add` for Merging Lists  

```python
from typing import Annotated
from typing_extensions import TypedDict
from operator import add

class State(TypedDict):
    foo: int
    bar: Annotated[list[str], add]  # Custom reducer (add function)

# Initial State
state = {"foo": 1, "bar": ["hi"]}

# First Node returns an update
update_1 = {"foo": 2}  # foo is replaced
state.update(update_1)
print(state)  
# Output: {'foo': 2, 'bar': ['hi']}

# Second Node updates "bar" using "add" reducer
update_2 = {"bar": ["bye"]}
state["bar"] += update_2["bar"]  # Manually applying add reducer
print(state)  
# Output: {'foo': 2, 'bar': ['hi', 'bye']} (bar list merged)
```

### 🛠 Explanation  
- `foo` follows the **default reducer** and gets **overwritten**.  
- `bar` follows a **custom reducer** (`operator.add`), so new items are **appended** instead of replacing the old ones.  

### 🌍 Real-World Example:  
Imagine a **chat application** where new messages **add** to the chat history instead of replacing it.  
- First message: `["Hello"]`  
- Second message: `["How are you?"]`  
- Final state: `["Hello", "How are you?"]`

---

## 🏆 3. Alternative Custom Reducers  
We can define other reducers based on different needs.

### 🔹 Example 1: Keeping the Maximum Value  

```python
from typing import Annotated
from typing_extensions import TypedDict
from builtins import max  # Use max function as a reducer

class State(TypedDict):
    score: Annotated[int, max]  # Keep the highest value

# Initial State
state = {"score": 50}

# First Node updates the score
update_1 = {"score": 60}
state["score"] = max(state["score"], update_1["score"])
print(state)  
# Output: {'score': 60}  (Keeps the highest score)

# Second Node tries a lower score update
update_2 = {"score": 55}
state["score"] = max(state["score"], update_2["score"])
print(state)  
# Output: {'score': 60} (Remains the highest)
```

### 🌍 Real-World Example:  
This can be used in a **gaming leaderboard**, where the **highest score** is always stored.

---

### 🔹 Example 2: Keeping the Most Recent Value (Latest Update Wins)  

```python
from typing import Annotated
from typing_extensions import TypedDict

class State(TypedDict):
    last_updated: Annotated[str, lambda old, new: new]  # Always replace

# Initial State
state = {"last_updated": "2024-02-10"}

# First Node updates the timestamp
update_1 = {"last_updated": "2024-02-11"}
state["last_updated"] = update_1["last_updated"]
print(state)  
# Output: {'last_updated': '2024-02-11'} (Latest value replaces old)

# Second Node updates again
update_2 = {"last_updated": "2024-02-12"}
state["last_updated"] = update_2["last_updated"]
print(state)  
# Output: {'last_updated': '2024-02-12'} (Again, latest value wins)
```

### 🌍 Real-World Example:  
This can be used in **real-time applications** like **stock price tracking**, where the latest value should always be shown.

---

### 🔹 Example 3: Combining Dictionaries  

```python
from typing import Annotated
from typing_extensions import TypedDict
from functools import reduce

class State(TypedDict):
    data: Annotated[dict, lambda old, new: {**old, **new}]  # Merge dictionaries

# Initial State
state = {"data": {"name": "Alice"}}

# First Node updates the dictionary
update_1 = {"data": {"age": 25}}
state["data"] = {**state["data"], **update_1["data"]}
print(state)  
# Output: {'data': {'name': 'Alice', 'age': 25}} (Merged dictionaries)

# Second Node updates again
update_2 = {"data": {"city": "New York"}}
state["data"] = {**state["data"], **update_2["data"]}
print(state)  
# Output: {'data': {'name': 'Alice', 'age': 25, 'city': 'New York'}} (Merged again)
```

### 🌍 Real-World Example:  
This is useful in **user profile management** where new fields **add to** existing user data.

---

## 🎯 Summary  
| Reducer Type | Behavior | Example Use Case |
|-------------|----------|------------------|
| **Default Reducer** | Replaces the old value | Shopping cart where last selection replaces previous ones |
| **List Append Reducer** | Merges lists instead of replacing | Chat history, log messages |
| **Max Reducer** | Keeps the highest value | Game leaderboard |
| **Latest Value Reducer** | Keeps the most recent update | Stock prices, real-time data |
| **Dictionary Merge Reducer** | Merges dictionary updates | User profile updates |

---

## 🚀 Key Takeaways  
✅ Reducers control how **state updates** apply to existing values.  
✅ Default reducers **replace** values, while custom reducers **merge** or **modify** updates.  
✅ Different use cases require different **reducer strategies**.  

Let me know if you need more **examples** or **clarifications**! 🚀