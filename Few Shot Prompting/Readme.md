# 🛠️ **Few-Shot Prompting to Improve Tool-Calling Performance**  

Few-shot prompting is a technique used in Large Language Models (LLMs) to improve tool-calling performance by providing a few example inputs and outputs in the model prompt. This technique helps the model generate more accurate results, especially in complex tasks. Let’s dive deep into how this works, the experiments conducted, and real-world applications.

---

## 🔍 **What is Few-Shot Prompting?**  
Few-shot prompting refers to the practice of giving an LLM a small set of example inputs and expected outputs before asking it to process a new request. This helps the model better understand the task and produce more accurate responses.  

### 📝 **Types of Prompting**
1. **Zero-shot prompting** – The model is given no examples, only the instruction and query.
2. **One-shot prompting** – A single example is provided.
3. **Few-shot prompting** – A few examples (usually 2-10) are provided.
4. **Many-shot prompting** – A large number of examples are provided.

📌 **Real-World Example:**  
Imagine training a new cashier. Instead of just telling them to scan items (zero-shot), you show them one or two examples (one-shot) or several transactions (few-shot) before letting them work on their own.

---

## ⚙️ **Experiments on Few-Shot Prompting**
To measure the effectiveness of few-shot prompting, experiments were conducted on two datasets:  

1️⃣ **Query Analysis** – Selecting the correct search indexes based on user queries.  
2️⃣ **Multiverse Math** – Performing function-based mathematical operations while ignoring standard mathematical rules.

---

## 🧪 **Query Analysis Experiment**
### **📝 Goal:**  
Determine how well the model selects the appropriate search index based on a complex question.

### **🔎 Example Data Point:**  
```json
{
  "question": "What are best practices for setting up a document loader for a RAG chain?",
  "reference": [
    {
      "args": {
        "query": "document loader for RAG chain",
        "source": "langchain"
      },
      "name": "DocQuery"
    },
    {
      "args": {
        "authors": null,
        "subject": "document loader best practices",
        "end_date": null,
        "start_date": null
      },
      "name": "BlogQuery"
    }
  ]
}
```
Here, the model needs to decide which search tools to use. Without few-shot prompting, it might select only one tool, but with proper prompting, it learns that both `DocQuery` and `BlogQuery` are needed.

### **🔬 Few-Shot Techniques Tested**
1. **Zero-shot:** No examples provided.
2. **Few-shot-static-msgs, k=3:** Three fixed examples added.
3. **Few-shot-dynamic-msgs, k=3:** Three dynamically selected examples based on similarity.
4. **Few-shot-str, k=13:** Thirteen examples appended as a single string.
5. **Few-shot-msgs, k=13:** Thirteen examples formatted as messages.

### **📊 Key Findings:**
- Few-shot prompting **significantly improved accuracy**.
- Using **three semantically similar examples** provided better results than three static examples.
- **Using message format** was more effective than a single long string.
- Claude models benefited more from few-shot prompting than GPT models.

### **✅ Example of Model Improvement**
**❌ Incorrect Output (Zero-Shot):**
```json
{
  "name": "DocQuery",
  "args": {
    "query": "case studies agents running swe-benchmark",
    "source": "langchain"
  }
}
```
**✅ Corrected Output (Few-Shot):**
```json
[
  {
    "name": "BlogQuery",
    "args": {
      "subject": "agents swe-benchmark case study",
      "authors": "null",
      "end_date": "null",
      "start_date": "null"
    }
  },
  {
    "name": "DocQuery",
    "args": {
      "query": "agents running on swe-benchmark case study",
      "source": "langchain"
    }
  }
]
```
Few-shot prompting helped the model recognize the need to query both blogs and documents.

---

## 🔢 **Multiverse Math Experiment**
### **📝 Goal:**  
Test how well the model follows tool-specific mathematical rules instead of relying on its internal math knowledge.

### **🔎 Example Function:**
```python
def add(a: float, b: float) -> float:
    """Add two numbers; a + b."""
    return a + b + 1.2
```
This function does **not** perform normal addition. Instead, it adds **1.2 extra** to the sum. If the model ignores this and calculates `2 + 3 = 5`, it will be incorrect.

### **🔢 Example Question:**
**"Evaluate the sum of numbers 1 through 10 using only the add function."**  

**✅ Expected Tool Calls:**
```python
add(1, 2)
add(x, 3)
add(x, 4)
...
add(x, 10)
```

### **📊 Key Findings:**
- Few-shot prompting improved the model's ability to follow rules.
- The model initially **ignored** tool results but learned after correction.
- **Nine-shot prompting** (using 9 examples) was the most effective.

### **🛠 Example Correction**
❌ **Incorrect Answer (Zero-Shot):**
```json
{
  "tool_calls": [{"name": "negate", "args": {"a": -100}}]
}
```
Expected output: `-100.0`, but the model mistakenly said `100`.

✅ **Corrected Answer (Few-Shot):**
```json
{
  "tool_calls": [{"name": "negate", "args": {"a": -100}}]
}
```
The model originally **ignored** the function output, but after few-shot prompting, it correctly followed the tool behavior.

---

## 🎯 **Best Practices for Few-Shot Prompting**
1. **Use semantically similar examples** – Instead of random samples, select relevant ones.
2. **Format as messages instead of plain text** – Structured messages help more.
3. **Balance the number of examples** – More is better, but beyond a point, it doesn’t add much value.
4. **Iterate and refine** – Run experiments to find the best prompt structure.

---

## 🌍 **Real-World Applications**
🚀 **Chatbots & Virtual Assistants:** Improve response accuracy in AI-driven customer support.  
📊 **Data Retrieval Systems:** Help models pick the right database indexes for queries.  
📚 **Automated Research Tools:** Guide models to find relevant research papers.  
🤖 **AI Agents & Autonomous Systems:** Enhance performance in complex reasoning tasks.  

---

## 🏁 **Conclusion**
Few-shot prompting **greatly improves** the ability of LLMs to follow tool-calling instructions. By carefully selecting **semantically relevant examples** and formatting them properly, we can **significantly enhance accuracy** in AI models.  

Would you like help implementing few-shot prompting in your AI project? 🚀