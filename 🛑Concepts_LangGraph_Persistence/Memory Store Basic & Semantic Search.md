## 🧠 Understanding Memory Store in LangGraph

A **Memory Store** in LangGraph is a way to persist and retrieve shared state across different executions (threads) of a graph. It enables us to store and manage data beyond a single execution. This is useful for scenarios like chatbots, where we need to remember user preferences across different interactions.

---

## 📌 **Why Do We Need a Memory Store?**
When executing a graph:
- **Checkpoints** store state within a single thread (execution path).
- **Memory Store** allows sharing of data **across multiple threads**.

### 📍 **Real-World Use Case**
Consider a **chatbot for a food delivery app**:
- A user interacts with the chatbot across multiple sessions.
- The chatbot needs to **remember user preferences** (e.g., "I like pizza").
- If we store this data in a **Memory Store**, it will persist across different chat sessions.

---

## 🚀 **Basic Usage of In-Memory Store**
LangGraph provides an `InMemoryStore` to store and retrieve data easily.

### **Step 1: Import and Initialize Memory Store**
```python
from langgraph.store.memory import InMemoryStore

# Create an in-memory store
in_memory_store = InMemoryStore()
```
✅ **What this does?**  
This initializes an **in-memory store** where we can store and retrieve data.

---

### **Step 2: Define a Namespace for Memory**
```python
user_id = "1"
namespace_for_memory = (user_id, "memories")
```
✅ **What this does?**  
- Each **memory entry** is stored under a unique **namespace**.
- Here, we use the **user's ID** to group all memories of a particular user.

---

### **Step 3: Store a Memory**
```python
import uuid  # Generate unique IDs

memory_id = str(uuid.uuid4())  # Unique ID for the memory
memory = {"food_preference": "I like pizza"}

# Store the memory in the namespace
in_memory_store.put(namespace_for_memory, memory_id, memory)
```
✅ **Explanation**  
- We generate a **unique memory ID** using `uuid`.
- We define the **memory** as a dictionary (`{"food_preference": "I like pizza"}`).
- `put()` stores the memory under the defined namespace.

---

### **Step 4: Retrieve Stored Memory**
```python
# Retrieve memories for this user
memories = in_memory_store.search(namespace_for_memory)

# Get the most recent memory
latest_memory = memories[-1].dict()
print(latest_memory)
```
✅ **Explanation**  
- `search()` fetches **all stored memories** for a given namespace.
- The **most recent memory** is the last item in the list.
- `.dict()` converts the memory object into a readable dictionary.

🔹 **Example Output:**
```json
{
    "value": {"food_preference": "I like pizza"},
    "key": "07e0caf4-1631-47b7-b15f-65515d4c1843",
    "namespace": ["1", "memories"],
    "created_at": "2024-10-02T17:22:31.590602+00:00",
    "updated_at": "2024-10-02T17:22:31.590605+00:00"
}
```

---

## 🔍 **Attributes of Stored Memory**
Each memory contains:
1. **`value`** → The actual data stored (e.g., `"food_preference": "I like pizza"`).
2. **`key`** → A unique identifier for the memory.
3. **`namespace`** → The namespace where the memory is stored (e.g., `["1", "memories"]`).
4. **`created_at`** → Timestamp of memory creation.
5. **`updated_at`** → Timestamp of last update.

---

## 🤖 **Advanced Feature: Semantic Search**
Instead of exact keyword matches, we can search **based on meaning** using embeddings.

### **Step 1: Enable Semantic Search**
```python
from langchain.embeddings import init_embeddings

store = InMemoryStore(
    index={
        "embed": init_embeddings("openai:text-embedding-3-small"),  # Embedding provider
        "dims": 1536,  # Embedding dimensions
        "fields": ["food_preference", "$"]  # Fields to embed
    }
)
```
✅ **Explanation**  
- We initialize **semantic embeddings** using OpenAI’s text embeddings.
- It allows us to **search memories by meaning** instead of exact keywords.

---

### **Step 2: Search Using Natural Language**
```python
# Find memories related to food preferences
memories = store.search(
    namespace_for_memory,
    query="What does the user like to eat?",
    limit=3  # Return top 3 matches
)
```
✅ **Explanation**  
- The **query** `"What does the user like to eat?"` retrieves relevant memories.
- Instead of **exact word matching**, it finds **contextually relevant** memories.

---

### **Step 3: Control Memory Indexing**
We can **choose what to embed** for better search efficiency.

```python
# Store memory with specific embedding fields
store.put(
    namespace_for_memory,
    str(uuid.uuid4()),
    {
        "food_preference": "I love Italian cuisine",
        "context": "Discussing dinner plans"
    },
    index=["food_preference"]  # Only index "food_preference"
)

# Store without embedding (not searchable via semantic search)
store.put(
    namespace_for_memory,
    str(uuid.uuid4()),
    {"system_info": "Last updated: 2024-01-01"},
    index=False  # Exclude from semantic search
)
```
✅ **Explanation**  
- `"food_preference"` is indexed for semantic search.
- `"system_info"` is stored but **not indexed**, so it won’t appear in search results.

---

## 🌟 **Final Thoughts**
### **📌 Key Takeaways**
✅ `InMemoryStore` allows **storing and retrieving memories across sessions**.  
✅ Data is stored in a **namespace**, usually based on user ID.  
✅ **Semantic search** makes retrieval more intelligent by understanding meaning.  
✅ We can **control what data is indexed** for optimized searches.  

### **💡 Real-World Applications**
🚀 **Chatbots** → Remember user preferences across multiple sessions.  
📊 **Customer Support** → Store conversation history for personalized assistance.  
🛍️ **E-Commerce** → Recall product preferences for personalized recommendations.  

With these concepts, you can build **intelligent memory-powered applications**! 🎯🚀