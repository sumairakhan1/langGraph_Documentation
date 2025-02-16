# 🏦 **Understanding Persistent Key-Value Stores in Storage Systems**

Persistent key-value stores are essential for managing long-term memory across applications. These stores support hierarchical namespaces, key-value storage, and optional vector search, making them useful in scenarios like caching, document storage, and user session management.

---

## 🔹 **1. What is a Persistent Key-Value Store?**

A **persistent key-value store** is a database system designed to store and retrieve data in key-value pairs that persist across threads and conversations.

### ✅ **Key Features:**
- **Long-Term Memory** – Data persists across system restarts.
- **Hierarchical Namespaces** – Organize data into categories.
- **Efficient Lookups** – Retrieve values quickly using keys.
- **Optional Vector Search** – Search based on similarity rather than exact matches.

---

## 🌍 **2. Real-World Use Cases**
Persistent key-value stores are widely used in real-world applications:

1. **🔹 User Sessions** – Storing logged-in user data (e.g., session tokens in Redis).
2. **🔹 Caching** – Speeding up web applications by storing frequently accessed data.
3. **🔹 Document Storage** – Organizing large-scale structured/unstructured data (e.g., MongoDB, DynamoDB).
4. **🔹 Machine Learning** – Storing embeddings for similarity searches.

---

## 🏗 **3. Core Components of Persistent Key-Value Stores**

### 🔹 **BaseStore: The Foundation**
The `BaseStore` is the core interface, providing both synchronous and asynchronous operations to manage stored data.

### 🔹 **Item: Storing Key-Value Pairs**
An `Item` represents stored data along with metadata like timestamps and namespace.

#### **Example**
```python
from datetime import datetime

class Item:
    def __init__(self, key: str, value: dict, namespace: tuple[str, ...]):
        self.key = key
        self.value = value
        self.namespace = namespace
        self.created_at = datetime.now()
        self.updated_at = datetime.now()

# Usage Example
user_data = Item("user123", {"name": "Alice", "age": 25}, ("users",))
print(user_data.key)         # Output: user123
print(user_data.namespace)   # Output: ('users',)
print(user_data.value)       # Output: {'name': 'Alice', 'age': 25}
```

### **🔎 Explanation**
- `key`: Unique identifier for the data.
- `value`: Dictionary containing stored information.
- `namespace`: Defines a hierarchical storage path.
- `created_at`, `updated_at`: Track creation and modification times.

---

## 🔄 **4. Operations in Persistent Storage**

### **🛠 Get/Put/Search/List Operations**
1. **Get** – Retrieve a stored item.
2. **Put** – Store a new item or update an existing one.
3. **Search** – Find items based on conditions.
4. **List** – Retrieve all items within a namespace.

#### **Example: Implementing a Simple Key-Value Store**
```python
class KeyValueStore:
    def __init__(self):
        self.store = {}

    def put(self, key, value):
        """ Store a key-value pair """
        self.store[key] = value

    def get(self, key):
        """ Retrieve a value by key """
        return self.store.get(key, "Key not found")

    def list_keys(self):
        """ List all keys in storage """
        return list(self.store.keys())

# Example Usage
db = KeyValueStore()
db.put("username", "Alice")
print(db.get("username"))  # Output: Alice
print(db.list_keys())      # Output: ['username']
```

### **🔎 Explanation**
- `put()`: Adds data to the store.
- `get()`: Retrieves data using a key.
- `list_keys()`: Lists all stored keys.

---

## 🔍 **5. Namespace and Hierarchy in Storage**

### **🔹 NamespacePath: Organizing Data**
Namespaces allow structured data storage, similar to folders in a filesystem.

#### **Example**
```python
namespace1 = ("users",)               # Users category
namespace2 = ("documents", "*")       # Any document subcategory
namespace3 = ("cache", "*", "v1")     # Versioned cache
```
- `("users",)`: Represents a strict category for users.
- `("documents", "*")`: Matches any subcategory under documents.
- `("cache", "*", "v1")`: Targets version 1 cache.

---

## 🔄 **6. Searching with Relevance Scores**
### **SearchItem: Enhanced Search Results**
A `SearchItem` extends `Item` with a similarity score for ranked search results.

#### **Example**
```python
class SearchItem(Item):
    def __init__(self, namespace, key, value, score=None):
        super().__init__(key, value, namespace)
        self.score = score  # Relevance Score

# Example Usage
search_result = SearchItem(("documents",), "doc1", {"title": "AI Research"}, score=0.92)
print(search_result.score)  # Output: 0.92
```
- `score`: Represents search ranking (useful for similarity searches).

---

## 🚀 **7. Alternative Implementations**
### **🔹 Alternative 1: Using Redis for Persistent Storage**
```python
import redis

r = redis.Redis(host='localhost', port=6379, db=0)

# Store data
r.set("username", "Alice")

# Retrieve data
print(r.get("username").decode())  # Output: Alice
```
✅ **Why Use Redis?**
- Fast in-memory storage.
- Supports persistence to disk.
- Used for caching and real-time applications.

---

### **🔹 Alternative 2: Using JSON for Key-Value Storage**
```python
import json

data_store = {}

# Store data
data_store["user"] = json.dumps({"name": "Alice", "age": 25})

# Retrieve data
print(json.loads(data_store["user"]))  # Output: {'name': 'Alice', 'age': 25}
```
✅ **Why Use JSON?**
- Human-readable format.
- Easy to store in files and databases.

---

### **🔹 Alternative 3: Using SQLite for Persistent Key-Value Store**
```python
import sqlite3

conn = sqlite3.connect("data.db")
cursor = conn.cursor()

# Create table
cursor.execute("CREATE TABLE IF NOT EXISTS storage (key TEXT, value TEXT)")

# Insert data
cursor.execute("INSERT INTO storage (key, value) VALUES (?, ?)", ("username", "Alice"))
conn.commit()

# Retrieve data
cursor.execute("SELECT value FROM storage WHERE key=?", ("username",))
print(cursor.fetchone()[0])  # Output: Alice

conn.close()
```
✅ **Why Use SQLite?**
- Lightweight and file-based.
- Supports structured queries.

---

## 🎯 **Conclusion**
Persistent key-value stores are essential for managing structured data in a scalable, efficient manner. They are widely used in real-world applications, from caching to search engines.

### **🔑 Key Takeaways**
- **Stores provide long-term memory for applications.**
- **Namespaces help in organizing data hierarchically.**
- **Operations include Get, Put, Search, and List.**
- **Alternative implementations include Redis, JSON, and SQLite.**

🚀 **By understanding key-value stores, you can efficiently manage and retrieve data in modern applications!**

---


# 🏛️ **Understanding Persistent Key-Value Stores in Python**  

Persistent key-value stores provide long-term memory for applications, allowing efficient retrieval, storage, and search operations. These stores support **hierarchical namespaces**, **key-value storage**, and even **vector-based searching** for AI-driven applications.

---
## 🔥 **Core Concepts of Persistent Key-Value Stores**
### 📌 **1. BaseStore - The Core of Persistent Storage**  
The `BaseStore` class serves as the foundation for any persistent key-value store. It provides methods for storing and retrieving items across sessions, ensuring that the data persists even when the program restarts.

### 📌 **2. Item - The Fundamental Storage Unit**  
An `Item` is the main entity in a key-value store, consisting of:  
✅ A unique `key` (e.g., `"user123"`)  
✅ A `namespace` that categorizes it (e.g., `("users", "profiles")`)  
✅ A `value` that holds the actual data  
✅ `created_at` and `updated_at` timestamps  

### 📌 **3. Namespace Paths - Organizing Data**  
Namespaces help **categorize data hierarchically**, just like folders on a computer.  
Examples:  
- `("users",)` → Stores all users  
- `("documents", "*")` → Any document-related data  
- `("cache", "*", "v1")` → Caching for version 1 data  

### 📌 **4. Operations - Interacting with the Store**  
There are two key operations for interacting with stored data:  
- **GetOp** 🧐 → Retrieves an item using a `namespace` and `key`  
- **SearchOp** 🔍 → Searches for items using filters or natural language  

---

## 🛠️ **1. Retrieving Items Using `GetOp`**  

### **📜 Definition**
The `GetOp` class helps fetch a specific item by its **namespace** and **key**.  

### **🔹 Real-World Example**
Imagine a **user profile management system**. To fetch user data, we use `GetOp` like this:  
- Namespace: `("users", "profiles")`  
- Key: `"user123"`  

### **📝 Code Example**
```python
from typing import NamedTuple

class GetOp(NamedTuple):
    """Retrieve an item using its namespace and key."""
    namespace: tuple[str, ...]  # Path in the storage system
    key: str  # Unique identifier

# Example usage:
user_retrieval = GetOp(namespace=("users", "profiles"), key="user123")

# Output the retrieval operation
print(user_retrieval)
```

### **📌 Explanation**
1️⃣ `NamedTuple` is used for structured data storage.  
2️⃣ `namespace: tuple[str, ...]` defines a hierarchical structure.  
3️⃣ `key: str` is the **unique identifier** for the stored item.  
4️⃣ We instantiate `GetOp` with `"user123"` under `("users", "profiles")`.  

---

## 🔍 **2. Searching for Items Using `SearchOp`**

### **📜 Definition**
The `SearchOp` class allows searching for items based on **filters** (structured search) or **natural language** (semantic search).  

### **🔹 Real-World Example**
In a **document management system**, users might want to search for reports with a **specific type and status** or use **natural language queries** to find relevant documents.  

### **📝 Code Example**
```python
from typing import Optional, Any

class SearchOp(NamedTuple):
    """Search for items within a namespace using structured filtering or natural language."""
    namespace_prefix: tuple[str, ...]  # Path to search within
    filter: Optional[dict[str, Any]] = None  # Filtering conditions
    limit: int = 10  # Number of results to return
    offset: int = 0  # Pagination support
    query: Optional[str] = None  # Natural language search

# Example: Search for active reports in the "documents" namespace
search_reports = SearchOp(
    namespace_prefix=("documents",),
    filter={"type": "report", "status": "active"},
    limit=5,
    offset=10
)

# Output search operation
print(search_reports)
```

### **📌 Explanation**
1️⃣ `namespace_prefix`: Specifies the **search scope** (e.g., `("documents",)`).  
2️⃣ `filter`: Searches for **reports** that are **active** (`{"type": "report", "status": "active"}`).  
3️⃣ `limit`: Returns **5** results at most.  
4️⃣ `offset`: Skips **10** results for pagination.  

---

## 🚀 **3. Advanced Querying Using Operators**

### **🔹 Real-World Example**
In an **e-commerce application**, users may want to filter products:  
- Products with a **rating above 4.5**  
- Items with a **price between $50 and $100**  

### **📝 Code Example**
```python
# Example: Filter products with rating >= 4.5 and price <= 100
product_filter = {
    "rating": {"$gte": 4.5},  # Greater than or equal to 4.5
    "price": {"$lte": 100}  # Less than or equal to 100
}

# Example: Search operation
search_products = SearchOp(
    namespace_prefix=("products",),
    filter=product_filter,
    limit=10
)

# Output filter operation
print(search_products)
```

### **📌 Explanation**
- `$gte` (Greater than or equal) ensures only products rated **4.5 or higher** are fetched.  
- `$lte` (Less than or equal) ensures only products costing **$100 or less** are included.  

---

## 🎯 **Alternative Examples to Strengthen Understanding**
### 🏡 **Example 1: Property Listings Search**
A **real estate platform** wants to search for houses with:  
- Price **below $500,000**  
- Located in **New York**  
- At least **3 bedrooms**  
```python
house_filter = {
    "price": {"$lt": 500000},
    "location": "New York",
    "bedrooms": {"$gte": 3}
}
```

### 🎵 **Example 2: Music Streaming Search**
A **music app** allows users to search for songs:  
- By **genre** (`"pop"`)  
- With a **rating of at least 4 stars**  
```python
music_filter = {
    "genre": "pop",
    "rating": {"$gte": 4}
}
```

### 📚 **Example 3: Library Book Search**
A **library system** allows searching for books:  
- Published **after 2015**  
- Having **"machine learning"** in the title  
```python
book_filter = {
    "published_year": {"$gt": 2015},
    "title": {"$contains": "machine learning"}
}
```

---

## 🎯 **Conclusion**
✅ **Key-value stores** are great for structured, persistent storage.  
✅ `GetOp` retrieves **specific items**, while `SearchOp` helps **find relevant data**.  
✅ Advanced **filtering operators** allow powerful queries.  
✅ Used in **user management, e-commerce, real estate, music, and more!**  

Would you like an implementation of a simple key-value store? 🚀

---

# 📌 Understanding `MatchCondition` in Python  

The `MatchCondition` class is a **NamedTuple** used to define a pattern for matching namespaces in a data store. It allows filtering namespaces based on whether they start with (`prefix` match) or end with (`suffix` match) a certain pattern. This is useful in managing hierarchical data structures where items are grouped in nested categories.

---

## 🔍 What is `NamedTuple`?  

A `NamedTuple` is a special Python class from the `collections` module that acts like a regular tuple but allows accessing elements by name instead of index. It is useful when we need immutable, structured data with named attributes.  

### ✅ Example of a `NamedTuple`
```python
from collections import namedtuple

Person = namedtuple("Person", ["name", "age"])
p = Person(name="Alice", age=30)

print(p.name)  # Output: Alice
print(p.age)   # Output: 30
```
Now, let's dive into `MatchCondition` and how it works.

---

## 🏗️ Structure of `MatchCondition`  

### 🔹 Definition
```python
from typing import NamedTuple

class MatchCondition(NamedTuple):
    match_type: str  # Defines whether to match by prefix or suffix
    path: tuple[str, ...]  # The hierarchical path to match
```
### 📝 Explanation of Attributes
1. **`match_type` (str)**  
   - Determines the matching rule:  
     - `"prefix"` → Checks if a namespace **starts** with a given path  
     - `"suffix"` → Checks if a namespace **ends** with a given path  
2. **`path` (tuple[str, ...])**  
   - A tuple that defines the namespace hierarchy to match.  
   - Can include wildcards (`"*"`) to represent flexible matching.  

---

## 📌 Example 1: Prefix Matching  
```python
match_condition = MatchCondition(match_type="prefix", path=("users", "profiles"))
print(match_condition)
```
### 🔍 Explanation:
- `match_type="prefix"` → This means we are looking for namespaces that **start with** `("users", "profiles")`.
- This would match namespaces like:
  - `("users", "profiles", "settings")`
  - `("users", "profiles", "data")`
- **But not** `("admin", "users", "profiles")` since it does not start with `"users"`.

---

## 📌 Example 2: Suffix Matching  
```python
match_condition = MatchCondition(match_type="suffix", path=("cache", "*"))
print(match_condition)
```
### 🔍 Explanation:
- `match_type="suffix"` → This means we are looking for namespaces that **end with** `("cache", "*")`.
- The wildcard `"*"` allows any subpath to match.
- This would match namespaces like:
  - `("system", "cache", "session")`
  - `("user", "cache", "images")`
- **But not** `("cache", "user")` since it does not end with `"cache", "*"`.

---

## 📌 Example 3: Simple Suffix Matching  
```python
match_condition = MatchCondition(match_type="suffix", path=("v1",))
print(match_condition)
```
### 🔍 Explanation:
- This matches all namespaces ending in `"v1"`, such as:
  - `("api", "v1")`
  - `("config", "v1")`
- It **will not match** `("v1", "config")` since it does not end exactly in `"v1"`.

---

## 🏢 Real-World Use Cases  

🔹 **Database Management**:  
  - Helps filter database tables or collections by prefix/suffix (e.g., `users_*` tables).  
🔹 **File Systems**:  
  - Organizing directories by matching paths (e.g., all logs in `/var/logs/*`).  
🔹 **API Versioning**:  
  - Matching API routes ending in `v1`, `v2`, etc., in microservices.  
🔹 **Cache Management**:  
  - Identifying cache keys based on common patterns.  

---

## 🎯 Alternative Approaches  

### ✅ Using Regular Expressions (Regex)  
Instead of `MatchCondition`, we can use regex for more flexible pattern matching:  
```python
import re

def match_namespace(namespace, pattern):
    return bool(re.match(pattern, "/".join(namespace)))

# Match namespaces starting with "users/profiles"
print(match_namespace(["users", "profiles", "data"], r"^users/profiles"))
```

---

### ✅ Using List Filtering  
If we have a list of namespaces, we can filter using list comprehensions:  
```python
namespaces = [
    ("users", "profiles", "settings"),
    ("admin", "users", "profiles"),
    ("users", "profiles", "data"),
]

filtered = [ns for ns in namespaces if ns[:2] == ("users", "profiles")]
print(filtered)
```

---

### ✅ Using Python’s `startswith()` and `endswith()`  
For simple string-based namespace filtering:  
```python
namespace = ("users", "profiles", "settings")
if namespace[:2] == ("users", "profiles"):
    print("Matches prefix")
```

---

## 🎯 Summary  
- `MatchCondition` is useful for filtering namespaces based on `prefix` or `suffix`.  
- It helps in organizing hierarchical data structures efficiently.  
- Alternative approaches include **Regex**, **List Filtering**, and **String Matching**.  

Would you like me to expand on any part? 🚀

---


# 📌 Understanding `ListNamespacesOp` in Python  

The `ListNamespacesOp` class is a **NamedTuple** that helps in filtering and listing namespaces in a store. It is commonly used in hierarchical data systems where namespaces (such as folders, collections, or API endpoints) are structured in a tree-like format.  

---

# 🏗️ What is `ListNamespacesOp`?  

The `ListNamespacesOp` class allows you to:  
✅ Explore and navigate namespaces in a structured way.  
✅ Apply filters to list only specific namespaces.  
✅ Control the depth of search in a namespace hierarchy.  
✅ Limit the number of results and use pagination.  

---

# 🔍 Structure of `ListNamespacesOp`  

### 🔹 Definition  
```python
from typing import NamedTuple, Optional

class ListNamespacesOp(NamedTuple):
    match_conditions: Optional[tuple["MatchCondition", ...]] = None
    max_depth: Optional[int] = None
    limit: int = 100
    offset: int = 0
```
### 📝 Explanation of Attributes  
| Attribute          | Type                               | Description |
|-------------------|--------------------------------|-------------|
| `match_conditions` | `Optional[tuple[MatchCondition, ...]]` | A tuple of conditions for filtering namespaces (e.g., by prefix or suffix). |
| `max_depth`       | `Optional[int]`               | Defines how deep to search in the namespace hierarchy. |
| `limit`           | `int`                         | The maximum number of namespaces to return (default: `100`). |
| `offset`          | `int`                         | The number of namespaces to skip for pagination (default: `0`). |

---

# 📌 Example 1: Listing Namespaces by Prefix  
```python
ListNamespacesOp(
    match_conditions=(MatchCondition(match_type="prefix", path=("documents",)),),
    max_depth=2
)
```
### 🔍 Explanation:  
1. **`match_conditions=(MatchCondition(match_type="prefix", path=("documents",)),)`**  
   - This filters namespaces that **start with** `"documents"`.  
   - Matches examples:  
     - `("documents", "files")`  
     - `("documents", "2024")`  
   - Does **not** match `("users", "documents")`.  
2. **`max_depth=2`**  
   - Restricts the search to **two levels deep**, meaning only subdirectories within `"documents"` will be included.  

---

# 📌 Example 2: Listing Namespaces by Suffix  
```python
ListNamespacesOp(
    match_conditions=(MatchCondition(match_type="suffix", path=("v1",)),),
    limit=50
)
```
### 🔍 Explanation:  
1. **`match_conditions=(MatchCondition(match_type="suffix", path=("v1",)),)`**  
   - This filters namespaces that **end with** `"v1"`.  
   - Matches:  
     - `("api", "v1")`  
     - `("config", "v1")`  
   - Does **not** match `("v1", "config")`.  
2. **`limit=50`**  
   - Restricts the results to a **maximum of 50 namespaces**.  

---

# 📌 Example 3: Multiple Match Conditions  
```python
ListNamespacesOp(
    match_conditions=(
        MatchCondition(match_type="prefix", path=("docs",)),
        MatchCondition(match_type="suffix", path=("draft",))
    )
)
```
### 🔍 Explanation:  
1. **`match_conditions=()`**  
   - This applies **multiple filters**:  
     - Only namespaces **starting with** `"docs"`.  
     - Only namespaces **ending with** `"draft"`.  
   - Matches:  
     - `("docs", "articles", "draft")`  
     - `("docs", "notes", "draft")`  
   - Does **not** match `("users", "docs", "draft")`.  

---

# 🏢 Real-World Use Cases  

🔹 **Database Management**  
   - Searching for specific database collections (e.g., `users_*` collections).  
🔹 **File Systems**  
   - Filtering directories based on folder structures (e.g., `documents/*`).  
🔹 **API Versioning**  
   - Managing API versions efficiently (e.g., `api/v1`, `api/v2`).  
🔹 **Cloud Storage**  
   - Organizing cloud storage objects (e.g., `projects/2024/*`).  

---

# 🎯 Alternative Approaches  

### ✅ Using List Comprehensions  
```python
namespaces = [("users", "profiles"), ("docs", "draft"), ("users", "settings")]
filtered = [ns for ns in namespaces if ns[0] == "docs" and ns[-1] == "draft"]
print(filtered)
```
✔️ Simple filtering approach without needing NamedTuples.  

---

### ✅ Using Regular Expressions (Regex)  
```python
import re

def match_namespace(namespace, pattern):
    return bool(re.match(pattern, "/".join(namespace)))

# Match namespaces starting with "docs" and ending with "draft"
print(match_namespace(["docs", "articles", "draft"], r"^docs.*draft$"))
```
✔️ More flexible pattern matching.  

---

### ✅ Using `startswith()` and `endswith()`  
```python
namespace = ("docs", "articles", "draft")

if namespace[0] == "docs" and namespace[-1] == "draft":
    print("Namespace matches the conditions")
```
✔️ Simple approach for prefix and suffix filtering.  

---

# 🎯 Summary  
- `ListNamespacesOp` helps in filtering namespaces based on prefix, suffix, and hierarchy depth.  
- It is useful in **database management, API handling, and file systems**.  
- Alternative approaches include **List Filtering, Regex, and String Matching**.  

Would you like a practical coding exercise to reinforce learning? 🚀

---

# 🗂️ **Understanding `PutOp` in Detail**  

The `PutOp` class represents an **operation** to **store, update, or delete an item** in a structured data store. This class is based on Python’s **NamedTuple**, making it an immutable and structured way to define data.  

We’ll break it down step by step, understand **real-world applications**, provide **code examples**, and explore **alternative implementations**.  

---

## 🏗 **What is `PutOp`?**  

The `PutOp` class allows you to:  
✅ **Store** new data in a structured database.  
✅ **Update** existing data while maintaining indexing/search capabilities.  
✅ **Delete** an item by setting its value to `None`.  

It uses a **hierarchical namespace** (like folders) to organize stored data.

---

## 🌍 **Real-World Example**  

Imagine you're building a **document storage system** like Google Drive. Each user has their own documents, and files are stored in a structured manner.  

For example:  
- A **namespace** like `("documents", "user123")` represents a folder named **documents/user123**.  
- A **key** like `"report1"` represents a specific file inside the folder.  
- A **value** stores the file's metadata and contents.  
- A **deletion operation** is triggered by setting the value to `None`.  

---

## 📌 **Key Components of `PutOp`**  

### 1️⃣ **Namespace (`namespace`)**  
A **tuple** representing a hierarchical path to organize data.  

📌 **Think of it like folders in a file system!**  

#### ✅ **Examples**  
```python
("documents",)                     # Root-level documents
("documents", "user123")            # Documents for a specific user
("cache", "embeddings", "v1")       # Caching structure for machine learning embeddings
```
👉 **Why use namespaces?**  
They make it easy to structure and locate data efficiently.

---

### 2️⃣ **Key (`key`)**  
A **unique identifier** for the item inside the namespace.  

#### ✅ **Example**  
```python
namespace = ("documents", "user123")
key = "report1"
```
This means the **full path** is:  
📁 `"documents/user123/report1"`

---

### 3️⃣ **Value (`value`)**  
The **actual data** being stored. It must be a **dictionary** with string keys and **JSON-serializable** values.

#### ✅ **Example**  
```python
{
    "title": "Project Report",
    "author": "Alice",
    "content": "This is the full report content...",
    "metadata": {
        "created_at": "2025-02-16",
        "tags": ["business", "finance"]
    }
}
```
👉 **To delete an item**, set `value = None`.

---

### 4️⃣ **Index (`index`)**  
Controls how the item is indexed for **search operations**.

#### ✅ **Options**  
- `None` → Uses store defaults.  
- `False` → Disables indexing.  
- `list[str]` → Index specific fields.  

#### ✅ **Example of Indexing**  
```python
[
    "metadata.title",              # Index the document title
    "content",                     # Index full content
    "metadata.tags[*]",            # Index all tags
    "author"                       # Index the author name
]
```
👉 **Why index?**  
It enables **fast searching** and **retrieval**.

---

## 🖥 **Code Example with Explanation**  

Let’s implement an example where we:  
1️⃣ Store a **new document**.  
2️⃣ Update the document’s **metadata**.  
3️⃣ Delete the document.  

```python
from typing import NamedTuple, Optional, Union, Literal

# Define a MatchCondition class (if needed for filtering)
class MatchCondition(NamedTuple):
    match_type: str
    path: tuple[str, ...]

# Define PutOp class
class PutOp(NamedTuple):
    namespace: tuple[str, ...]  # Folder-like hierarchy
    key: str                    # Unique identifier for the item
    value: Optional[dict[str, Union[str, int, float, dict]]] = None  # Data to store
    index: Optional[Union[Literal[False], list[str]]] = None  # Indexing configuration

# 1️⃣ Storing a new document
store_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "title": "Annual Report",
        "author": "Alice",
        "content": "This is the annual financial report...",
        "metadata": {"tags": ["finance", "2025"], "created_at": "2025-02-16"}
    },
    index=["metadata.title", "content"]  # Index title and content
)
print(store_op)

# 2️⃣ Updating metadata
update_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "metadata": {"tags": ["finance", "2025", "audit"], "updated_at": "2025-02-17"}
    }
)
print(update_op)

# 3️⃣ Deleting the document
delete_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value=None  # Setting value to None deletes the item
)
print(delete_op)
```

---

## 🔎 **Explanation of the Code**  

### ✅ **Defining the `PutOp` Class**  
```python
class PutOp(NamedTuple):
```
- This class **inherits** from `NamedTuple`, making it **immutable** and **structured**.  
- It represents a **single operation** (store/update/delete).  

### ✅ **Storing a Document**  
```python
store_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "title": "Annual Report",
        "author": "Alice",
        "content": "This is the annual financial report...",
        "metadata": {"tags": ["finance", "2025"], "created_at": "2025-02-16"}
    },
    index=["metadata.title", "content"]
)
```
- **Namespace**: `"documents/user123"` → Acts like a folder structure.  
- **Key**: `"report1"` → Identifies the document.  
- **Value**: Stores metadata and content.  
- **Index**: Allows **searching** for `title` and `content`.  

### ✅ **Updating Metadata**  
```python
update_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "metadata": {"tags": ["finance", "2025", "audit"], "updated_at": "2025-02-17"}
    }
)
```
- This operation **updates** the metadata **without** changing the content.  

### ✅ **Deleting a Document**  
```python
delete_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value=None  # Deletion operation
)
```
- Setting `value = None` **removes** the item.  

---

## 🔄 **Alternative Implementations**  

### 🅰 **Using a Dictionary Instead of NamedTuple**  
```python
store_op = {
    "namespace": ("documents", "user123"),
    "key": "report1",
    "value": {"title": "Annual Report", "content": "..."},
    "index": ["metadata.title"]
}
```
🔹 **Pros**: More flexible.  
🔹 **Cons**: Less structured.  

---

### 🅱 **Using a Class with `__init__`**  
```python
class PutOperation:
    def __init__(self, namespace, key, value=None, index=None):
        self.namespace = namespace
        self.key = key
        self.value = value
        self.index = index
```
🔹 **Pros**: More object-oriented.  
🔹 **Cons**: Requires extra boilerplate code.  

---

### 🅲 **Using JSON for Storage**  
```python
import json
store_json = json.dumps(store_op)
print(store_json)
```
🔹 **Pros**: Easy to serialize.  
🔹 **Cons**: Loses type safety.  

---

## 🏁 **Conclusion**  
- `PutOp` is used to **store, update, and delete** items.  
- It organizes data **hierarchically** using **namespaces**.  
- It supports **indexing** for fast search.  
- Used in **real-world applications** like **document storage** and **caching**.  

Would you like additional examples or modifications? 🚀

---


# 🗂️ **Understanding `PutOp` in Detail**  

The `PutOp` class represents an **operation** to **store, update, or delete an item** in a structured data store. This class is based on Python’s **NamedTuple**, making it an immutable and structured way to define data.  

We’ll break it down step by step, understand **real-world applications**, provide **code examples**, and explore **alternative implementations**.  

---

## 🏗 **What is `PutOp`?**  

The `PutOp` class allows you to:  
✅ **Store** new data in a structured database.  
✅ **Update** existing data while maintaining indexing/search capabilities.  
✅ **Delete** an item by setting its value to `None`.  

It uses a **hierarchical namespace** (like folders) to organize stored data.

---

## 🌍 **Real-World Example**  

Imagine you're building a **document storage system** like Google Drive. Each user has their own documents, and files are stored in a structured manner.  

For example:  
- A **namespace** like `("documents", "user123")` represents a folder named **documents/user123**.  
- A **key** like `"report1"` represents a specific file inside the folder.  
- A **value** stores the file's metadata and contents.  
- A **deletion operation** is triggered by setting the value to `None`.  

---

## 📌 **Key Components of `PutOp`**  

### 1️⃣ **Namespace (`namespace`)**  
A **tuple** representing a hierarchical path to organize data.  

📌 **Think of it like folders in a file system!**  

#### ✅ **Examples**  
```python
("documents",)                     # Root-level documents
("documents", "user123")            # Documents for a specific user
("cache", "embeddings", "v1")       # Caching structure for machine learning embeddings
```
👉 **Why use namespaces?**  
They make it easy to structure and locate data efficiently.

---

### 2️⃣ **Key (`key`)**  
A **unique identifier** for the item inside the namespace.  

#### ✅ **Example**  
```python
namespace = ("documents", "user123")
key = "report1"
```
This means the **full path** is:  
📁 `"documents/user123/report1"`

---

### 3️⃣ **Value (`value`)**  
The **actual data** being stored. It must be a **dictionary** with string keys and **JSON-serializable** values.

#### ✅ **Example**  
```python
{
    "title": "Project Report",
    "author": "Alice",
    "content": "This is the full report content...",
    "metadata": {
        "created_at": "2025-02-16",
        "tags": ["business", "finance"]
    }
}
```
👉 **To delete an item**, set `value = None`.

---

### 4️⃣ **Index (`index`)**  
Controls how the item is indexed for **search operations**.

#### ✅ **Options**  
- `None` → Uses store defaults.  
- `False` → Disables indexing.  
- `list[str]` → Index specific fields.  

#### ✅ **Example of Indexing**  
```python
[
    "metadata.title",              # Index the document title
    "content",                     # Index full content
    "metadata.tags[*]",            # Index all tags
    "author"                       # Index the author name
]
```
👉 **Why index?**  
It enables **fast searching** and **retrieval**.

---

## 🖥 **Code Example with Explanation**  

Let’s implement an example where we:  
1️⃣ Store a **new document**.  
2️⃣ Update the document’s **metadata**.  
3️⃣ Delete the document.  

```python
from typing import NamedTuple, Optional, Union, Literal

# Define a MatchCondition class (if needed for filtering)
class MatchCondition(NamedTuple):
    match_type: str
    path: tuple[str, ...]

# Define PutOp class
class PutOp(NamedTuple):
    namespace: tuple[str, ...]  # Folder-like hierarchy
    key: str                    # Unique identifier for the item
    value: Optional[dict[str, Union[str, int, float, dict]]] = None  # Data to store
    index: Optional[Union[Literal[False], list[str]]] = None  # Indexing configuration

# 1️⃣ Storing a new document
store_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "title": "Annual Report",
        "author": "Alice",
        "content": "This is the annual financial report...",
        "metadata": {"tags": ["finance", "2025"], "created_at": "2025-02-16"}
    },
    index=["metadata.title", "content"]  # Index title and content
)
print(store_op)

# 2️⃣ Updating metadata
update_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "metadata": {"tags": ["finance", "2025", "audit"], "updated_at": "2025-02-17"}
    }
)
print(update_op)

# 3️⃣ Deleting the document
delete_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value=None  # Setting value to None deletes the item
)
print(delete_op)
```

---

## 🔎 **Explanation of the Code**  

### ✅ **Defining the `PutOp` Class**  
```python
class PutOp(NamedTuple):
```
- This class **inherits** from `NamedTuple`, making it **immutable** and **structured**.  
- It represents a **single operation** (store/update/delete).  

### ✅ **Storing a Document**  
```python
store_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "title": "Annual Report",
        "author": "Alice",
        "content": "This is the annual financial report...",
        "metadata": {"tags": ["finance", "2025"], "created_at": "2025-02-16"}
    },
    index=["metadata.title", "content"]
)
```
- **Namespace**: `"documents/user123"` → Acts like a folder structure.  
- **Key**: `"report1"` → Identifies the document.  
- **Value**: Stores metadata and content.  
- **Index**: Allows **searching** for `title` and `content`.  

### ✅ **Updating Metadata**  
```python
update_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value={
        "metadata": {"tags": ["finance", "2025", "audit"], "updated_at": "2025-02-17"}
    }
)
```
- This operation **updates** the metadata **without** changing the content.  

### ✅ **Deleting a Document**  
```python
delete_op = PutOp(
    namespace=("documents", "user123"),
    key="report1",
    value=None  # Deletion operation
)
```
- Setting `value = None` **removes** the item.  

---

## 🔄 **Alternative Implementations**  

### 🅰 **Using a Dictionary Instead of NamedTuple**  
```python
store_op = {
    "namespace": ("documents", "user123"),
    "key": "report1",
    "value": {"title": "Annual Report", "content": "..."},
    "index": ["metadata.title"]
}
```
🔹 **Pros**: More flexible.  
🔹 **Cons**: Less structured.  

---

### 🅱 **Using a Class with `__init__`**  
```python
class PutOperation:
    def __init__(self, namespace, key, value=None, index=None):
        self.namespace = namespace
        self.key = key
        self.value = value
        self.index = index
```
🔹 **Pros**: More object-oriented.  
🔹 **Cons**: Requires extra boilerplate code.  

---

### 🅲 **Using JSON for Storage**  
```python
import json
store_json = json.dumps(store_op)
print(store_json)
```
🔹 **Pros**: Easy to serialize.  
🔹 **Cons**: Loses type safety.  

---

## 🏁 **Conclusion**  
- `PutOp` is used to **store, update, and delete** items.  
- It organizes data **hierarchically** using **namespaces**.  
- It supports **indexing** for fast search.  
- Used in **real-world applications** like **document storage** and **caching**.  

Would you like additional examples or modifications? 🚀

---

# 🚀 **Understanding `InvalidNamespaceError`, `IndexConfig`, and Embedding-Based Search in Python**

This guide explains **`InvalidNamespaceError`**, **`IndexConfig`**, and **embedding-based search** with **real-world examples**, **code snippets**, and **detailed explanations** for beginners.

---

## 🛑 **1. What is `InvalidNamespaceError`?**
### 🔍 **Definition**
`InvalidNamespaceError` is an **exception** that occurs when an invalid **namespace** (a hierarchical path used for organizing data) is provided.

### 🎯 **Real-World Example**
Imagine a **file system** where files are stored in folders (namespaces). If you try to access a file using an **invalid folder path**, you'll get an error. Similarly, in a database or search system, an invalid namespace can lead to `InvalidNamespaceError`.

### 📝 **Code Example**
```python
class InvalidNamespaceError(ValueError):
    """Raised when an invalid namespace is provided."""
    pass

def validate_namespace(namespace: tuple[str, ...]):
    """Check if the provided namespace is valid."""
    if not namespace or not all(isinstance(item, str) for item in namespace):
        raise InvalidNamespaceError("Provided namespace is invalid.")

# Example usage
try:
    validate_namespace(("documents", "user123"))  # ✅ Valid
    validate_namespace(("",))  # ❌ Invalid
except InvalidNamespaceError as e:
    print(e)
```
### 📌 **Explanation**
1. **Defined `InvalidNamespaceError`** (inherits from `ValueError`).
2. **`validate_namespace` function** checks if the namespace is valid:
   - Ensures **it's not empty**.
   - Checks if **all elements are strings**.
3. **Raises an error** if the namespace is invalid.

### ✅ **Alternative 3 Examples**
#### 1️⃣ Checking Namespace in a File System
```python
import os

def validate_directory(path: str):
    if not os.path.exists(path):
        raise InvalidNamespaceError(f"Invalid directory: {path}")

validate_directory("/valid/path")  # ✅ No error
validate_directory("/invalid/path")  # ❌ Raises InvalidNamespaceError
```
#### 2️⃣ Checking Namespace in a JSON-based Database
```python
def validate_json_namespace(json_obj, namespace):
    if namespace not in json_obj:
        raise InvalidNamespaceError(f"Namespace '{namespace}' not found in JSON.")

data = {"users": {}, "products": {}}
validate_json_namespace(data, "users")  # ✅ No error
validate_json_namespace(data, "orders")  # ❌ Raises InvalidNamespaceError
```
#### 3️⃣ Checking API Route Namespace
```python
VALID_NAMESPACES = {"users", "products", "orders"}

def validate_api_namespace(namespace):
    if namespace not in VALID_NAMESPACES:
        raise InvalidNamespaceError(f"Namespace '{namespace}' is not allowed.")

validate_api_namespace("users")  # ✅ No error
validate_api_namespace("payments")  # ❌ Raises InvalidNamespaceError
```

---

## 🔍 **2. What is `IndexConfig`?**
### 📌 **Definition**
`IndexConfig` is a **configuration object** that defines how **documents** should be indexed for **semantic search** using embeddings.

### 🎯 **Real-World Example**
Imagine you run a **library system** and want to allow users to **search for books** based on meaning rather than exact words. You'd use **embeddings** (vector representations of text) and an `IndexConfig` to define **how** book descriptions are stored for searching.

---

## ⚙️ **3. Understanding `dims` in `IndexConfig`**
### 🔍 **Definition**
The `dims` attribute specifies the **number of dimensions** in the **embedding vectors**.

### 📌 **Common Models and Their Dimensions**
| Model Name | Dimensions (`dims`) |
|------------|------------------|
| `text-embedding-3-large` (OpenAI) | 3072 |
| `text-embedding-3-small` (OpenAI) | 1536 |
| `embed-english-v3.0` (Cohere) | 1024 |
| `embed-multilingual-light-v3.0` (Cohere) | 384 |

### 📝 **Code Example**
```python
class IndexConfig:
    def __init__(self, dims: int):
        if dims <= 0:
            raise ValueError("dims must be a positive integer")
        self.dims = dims

# Example usage
config = IndexConfig(1536)  # ✅ Valid
invalid_config = IndexConfig(0)  # ❌ Raises ValueError
```
### 📌 **Explanation**
1. The `IndexConfig` class **validates** the number of dimensions.
2. If `dims` is **zero or negative**, it raises an error.

---

## 🔍 **4. Using `embed` for Text Embeddings**
### 🎯 **Definition**
The `embed` function is used to **convert text into vectors**.

### ✅ **Example 1: Using OpenAI's Embedding Model**
```python
from openai import OpenAI
from langgraph.store.memory import InMemoryStore

client = OpenAI()

def embed_texts(texts: list[str]) -> list[list[float]]:
    """Convert texts into embedding vectors."""
    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=texts
    )
    return [e.embedding for e in response.data]

store = InMemoryStore(
    index={
        "dims": 1536,
        "embed": embed_texts
    }
)
```
### 📌 **Explanation**
1. Uses `OpenAI`'s model to generate embeddings.
2. `embed_texts` takes a **list of texts** and converts them into **vectors**.
3. The `store` is configured to use `embed_texts` for indexing.

### ✅ **Example 2: Using a Custom Function**
```python
def custom_embed(texts: list[str]) -> list[list[float]]:
    """A simple mock embedding function."""
    return [[ord(c) for c in text] for text in texts]

config = IndexConfig(dims=10)
store = {"dims": config.dims, "embed": custom_embed}
```
### ✅ **Example 3: Using an Async Function**
```python
import asyncio

async def async_embed_texts(texts: list[str]) -> list[list[float]]:
    """Asynchronous embedding function."""
    await asyncio.sleep(1)  # Simulate async call
    return [[ord(c) for c in text] for text in texts]

config = IndexConfig(dims=10)
store = {"dims": config.dims, "embed": async_embed_texts}
```

---

## 🔍 **5. Indexing Specific Fields for Search**
### 📌 **Definition**
The `fields` parameter defines **which parts of a document** are indexed.

### ✅ **Examples**
| **Field Selector** | **Effect** |
|--------------------|-----------|
| `["$"]` | Indexes the **entire document** (default). |
| `["title", "summary"]` | Indexes only **title** and **summary**. |
| `["metadata.tags[*]"]` | Indexes **all tags in metadata**. |

### 📝 **Code Example**
```python
fields = ["title", "summary", "content.body"]
store = InMemoryStore(index={"dims": 1536, "embed": embed_texts, "fields": fields})
```
### 📌 **Explanation**
1. Only the `title`, `summary`, and `content.body` fields are indexed.

---

## 🎯 **Conclusion**
🔹 `InvalidNamespaceError` prevents invalid paths.  
🔹 `IndexConfig` helps configure **vector-based search**.  
🔹 `embed` converts **text into numerical vectors**.  
🔹 `fields` allow **targeted indexing**.

---
### 💡 **Real-World Use Cases**
✅ **E-commerce**: Searching for products using **semantic search**.  
✅ **Document Management**: Finding legal or research papers by **meaning**.  
✅ **Chatbots**: Understanding user **queries** using embeddings.

Would you like more real-world examples? 😊

---


That’s a lot of information! To make it easier to understand, I’ll break it down into sections with proper formatting, icons, real-world examples, and code explanations.

---

# 📌 Understanding `BaseStore`: An Abstract Persistent Key-Value Store

## 🔍 What is `BaseStore`?
`BaseStore` is an **abstract base class** for persistent key-value stores. It provides a structured way to store, retrieve, and search for data efficiently.

### 🏛️ Why Use `BaseStore`?
- **Persistent Storage**: Keeps data across sessions.
- **Namespace-based Organization**: Data is stored in a hierarchical format.
- **Supports Asynchronous Operations**: Optimized for performance.
- **Indexing & Searching**: Enables filtering and semantic search.

---

## 📌 Key Features of `BaseStore`
Let’s explore each feature with explanations, real-world examples, and code snippets.

---

## 1️⃣ **Batch Operations**
### 🔹 `batch(ops: Iterable[Op]) -> list[Result]`
Executes multiple operations **synchronously**.

**🔹 Real-World Use Case**  
Imagine you’re working on a banking system that needs to process multiple transactions at once. Instead of making multiple database calls, we execute all transactions in a single batch.

```python
# Example: Performing multiple operations at once
ops = [
    {"operation": "put", "key": "user_1", "value": {"balance": 5000}},
    {"operation": "put", "key": "user_2", "value": {"balance": 3000}}
]

results = store.batch(ops)
print(results)
```
**🛠 Explanation**  
- We define a list of operations (`ops`).
- Each operation stores user balance data.
- `store.batch(ops)` executes all operations at once.

### 🔹 `abatch(ops: Iterable[Op]) -> list[Result] async`
Executes operations **asynchronously**, allowing the system to handle more requests efficiently.

```python
import asyncio

async def run_batch():
    results = await store.abatch(ops)
    print(results)

asyncio.run(run_batch())
```
**🛠 Explanation**  
- We use `async` and `await` for non-blocking execution.
- `asyncio.run(run_batch())` runs the asynchronous batch process.

---

## 2️⃣ **Retrieving Data**
### 🔹 `get(namespace: tuple[str, ...], key: str) -> Optional[Item]`
Fetches a single item from storage.

**🔹 Real-World Use Case**  
Retrieving a user profile from a database.

```python
user = store.get(("users",), "user_1")
print(user)
```
**🛠 Explanation**  
- `"users"` is the namespace (category).
- `"user_1"` is the unique key.
- This fetches user data if it exists.

---

## 3️⃣ **Searching Data**
### 🔹 `search(namespace_prefix, query, filter, limit, offset)`
Finds data based on conditions.

**🔹 Real-World Use Case**  
Searching for published blog articles.

```python
results = store.search(
    ("docs",),
    filter={"type": "article", "status": "published"},
    limit=5
)
print(results)
```
**🛠 Explanation**  
- We look for `articles` that are `published`.
- The result is limited to **5 documents**.

#### 🆚 Alternative Approaches
| Approach | Description |
|----------|------------|
| **Direct Lookup** | Uses `get()` for exact match. |
| **Database Query** | Uses SQL queries for filtering. |
| **Full-text Search** | Uses a search engine (e.g., Elasticsearch). |

---

## 4️⃣ **Storing & Updating Data**
### 🔹 `put(namespace, key, value, index)`
Saves or updates an item in storage.

**🔹 Real-World Use Case**  
Storing user preferences in a system.

```python
store.put(("users",), "user_1", {"theme": "dark", "language": "en"})
```
**🛠 Explanation**  
- Stores the user’s theme and language settings.
- The key `"user_1"` uniquely identifies the user.

---

## 5️⃣ **Deleting Data**
### 🔹 `delete(namespace, key)`
Removes an item.

**🔹 Real-World Use Case**  
Deleting an expired API token.

```python
store.delete(("tokens",), "expired_token_123")
```
**🛠 Explanation**  
- Removes `"expired_token_123"` from `"tokens"`.

---

## 🎯 **Summary Table**
| Method | Purpose |
|--------|---------|
| `batch()` | Run multiple operations at once (sync). |
| `abatch()` | Run multiple operations asynchronously. |
| `get()` | Fetch a single item. |
| `search()` | Search for items with filters. |
| `put()` | Store or update an item. |
| `delete()` | Remove an item from storage. |

---

## 🚀 **Conclusion**
The `BaseStore` class provides a structured, efficient way to manage key-value storage with indexing and search capabilities. It is widely used in:
- **Databases**
- **Cache systems**
- **User settings storage**
- **Machine learning model indexing**

Would you like a deep dive into a specific area? 😊

---

Let's break this down in a detailed, beginner-friendly way with explanations, real-world use cases, and multiple examples.  

# 🚀 **Understanding `AsyncPostgresStore` in Detail**  

## 📌 **What is `AsyncPostgresStore`?**  
`AsyncPostgresStore` is an **asynchronous data store** backed by **PostgreSQL**. It allows efficient data storage and retrieval, and supports **vector search** when combined with `pgvector`.  

### 🔥 **Why Use It?**  
- **🔄 Asynchronous:** Improves performance by handling multiple tasks at once.  
- **🚀 Scalable:** Supports connection pooling for efficient database connections.  
- **📊 Vector Search:** Allows **semantic search** using **embeddings** (useful for AI applications).  
- **🛠 Efficient Data Retrieval:** Enables quick lookups using **keys**.  

---

# 🏗 **Real-World Use Cases**  
### 1️⃣ **User Preferences Storage**  
- Store and retrieve user settings (e.g., dark mode, language preference).  

### 2️⃣ **AI-Powered Search**  
- Use **vector embeddings** for **semantic search** in **chatbots** and **recommendation systems**.  

### 3️⃣ **High-Performance APIs**  
- Optimize **database queries** with **connection pooling** to improve response times.  

---

# 📌 **Basic Setup and Usage**  

## **🛠 1️⃣ Setting Up the Store**  
Before storing data, we need to initialize and configure `AsyncPostgresStore`.  

### **📜 Code Example:**  
```python
from langgraph.store.postgres import AsyncPostgresStore

# PostgreSQL connection string (replace with your actual credentials)
conn_string = "postgresql://user:pass@localhost:5432/dbname"

async with AsyncPostgresStore.from_conn_string(conn_string) as store:
    await store.setup()  # 🔹 Run migrations (Only needed once)

    # 🔹 Store user preferences
    await store.aput(("users", "123"), "prefs", {"theme": "dark"})

    # 🔹 Retrieve user preferences
    item = await store.aget(("users", "123"), "prefs")
    print(item)  # Output: {'theme': 'dark'}
```

### 🔍 **Explanation:**  
1. ✅ **Import `AsyncPostgresStore`** – This is our main class for interacting with PostgreSQL asynchronously.  
2. ✅ **Define `conn_string`** – This is the connection URL containing **username, password, host, port, and database name**.  
3. ✅ **Use `AsyncPostgresStore.from_conn_string()`** – Creates a connection to the database.  
4. ✅ **Call `setup()`** – Ensures necessary **tables and indexes** are created (only needed once).  
5. ✅ **Store user preferences using `aput()`** – Saves data for user **123** under the `"prefs"` key.  
6. ✅ **Retrieve stored data using `aget()`** – Fetches the stored preferences.  

---

# 📌 **2️⃣ Vector Search with LangChain Embeddings**  
`AsyncPostgresStore` supports **vector search** using `pgvector`, which is useful for **AI applications** like **semantic search** and **recommendation systems**.  

### **📜 Code Example:**  
```python
from langchain.embeddings import init_embeddings
from langgraph.store.postgres import AsyncPostgresStore

# PostgreSQL connection string
conn_string = "postgresql://user:pass@localhost:5432/dbname"

async with AsyncPostgresStore.from_conn_string(
    conn_string,
    index={
        "dims": 1536,  # 🔹 Vector dimensions
        "embed": init_embeddings("openai:text-embedding-3-small"),  # 🔹 Embedding model
        "fields": ["text"]  # 🔹 Specifies fields for embedding
    }
) as store:
    await store.setup()  # 🔹 Run migrations

    # 🔹 Store text documents with embeddings
    await store.aput(("docs",), "doc1", {"text": "Python tutorial"})
    await store.aput(("docs",), "doc2", {"text": "TypeScript guide"})
    await store.aput(("docs",), "doc3", {"text": "Other guide"}, index=False)  # Don't index this document

    # 🔹 Perform vector search
    results = await store.asearch(("docs",), "programming guides", limit=2)
    print(results)  # Returns the most relevant documents
```

### 🔍 **Explanation:**  
1. ✅ **Import `init_embeddings`** – Loads an embedding model to convert text into vectors.  
2. ✅ **Define `index` Configuration** – Specifies **vector dimensions (1536)** and the **embedding model**.  
3. ✅ **Store Text Data** – Saves documents with embeddings, enabling **semantic search**.  
4. ✅ **Search by Similarity (`asearch()`)** – Finds documents **related** to the input query.  

---

# 📌 **3️⃣ Connection Pooling for High Performance**  
Using a **connection pool** helps manage multiple database connections efficiently, improving **performance**.  

### **📜 Code Example:**  
```python
from langgraph.store.postgres import AsyncPostgresStore, PoolConfig

# PostgreSQL connection string
conn_string = "postgresql://user:pass@localhost:5432/dbname"

async with AsyncPostgresStore.from_conn_string(
    conn_string,
    pool_config=PoolConfig(
        min_size=5,  # 🔹 Minimum 5 connections
        max_size=20  # 🔹 Maximum 20 connections
    )
) as store:
    await store.setup()  # 🔹 Run migrations

    # 🔹 Perform database operations using the connection pool
    await store.aput(("users", "456"), "prefs", {"theme": "light"})
```

### 🔍 **Explanation:**  
1. ✅ **Define `PoolConfig`** – Manages multiple database connections.  
2. ✅ **Set `min_size` and `max_size`** – Controls how many connections can be **opened** at once.  
3. ✅ **Use `store` within the `async` block** – Ensures proper usage of pooled connections.  

---

# 🔄 **Alternative Examples for Better Understanding**  

## **📌 Example 1️⃣: Storing Chatbot Conversations**  
Imagine a chatbot **storing user messages** to improve responses.  
```python
await store.aput(("chats", "user1"), "session1", {"message": "Hello, how are you?"})
conversation = await store.aget(("chats", "user1"), "session1")
print(conversation)  # Output: {"message": "Hello, how are you?"}
```

---

## **📌 Example 2️⃣: Storing and Retrieving Orders in an E-Commerce App**  
```python
await store.aput(("orders", "order123"), "details", {"item": "Laptop", "price": 1000})
order = await store.aget(("orders", "order123"), "details")
print(order)  # Output: {"item": "Laptop", "price": 1000}
```

---

## **📌 Example 3️⃣: Using Vector Search for Movie Recommendations**  
```python
await store.aput(("movies",), "movie1", {"title": "Inception"}, index=True)
await store.aput(("movies",), "movie2", {"title": "The Matrix"}, index=True)
recommendations = await store.asearch(("movies",), "sci-fi movies", limit=2)
print(recommendations)  # Returns relevant movies
```

---

# 🚀 **Key Takeaways**  
✅ `AsyncPostgresStore` enables **fast, scalable, asynchronous data storage**.  
✅ Supports **vector search** for **AI-powered recommendations**.  
✅ **Connection pooling** improves **performance**.  
✅ Used in **chatbots, e-commerce, recommendation engines**, etc.  

This should give you a **strong** grasp of `AsyncPostgresStore`. Let me know if you need more examples! 🚀