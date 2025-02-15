# 🧠 **Understanding Few-Shot Prompting in AI Models**  

Few-shot prompting is an essential technique in prompt engineering that helps AI models generate better-structured and more relevant responses by providing a few examples within the prompt. This guide will break down the concept in detail, making it easy for beginners to understand, along with real-world use cases, alternative examples, and code snippets.  

---

## 🔍 **What is Few-Shot Prompting?**  

Few-shot prompting is a method where you provide the AI model with a few examples (or "shots") of how it should respond before asking it to generate a new response. This helps guide the model towards the expected structure and tone.  

### 🏆 **Why Use Few-Shot Prompting?**  
✅ Helps AI understand the expected response format.  
✅ Reduces randomness in AI-generated outputs.  
✅ Improves accuracy for complex or structured outputs.  
✅ Works well for structured data generation (e.g., JSON, TypedDict).  

---

# 🛠 **1. Basic Example of Few-Shot Prompting**  

## **📌 Step 1: Define a System Message with Examples**  
The **system message** acts as an instruction to the AI, telling it how to behave and what kind of responses to generate.  

### 📜 **Code Example**
```python
from langchain_core.prompts import ChatPromptTemplate

# Define the system message with examples
system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke with a setup and a punchline.

Here are some examples:

example_user: Tell me a joke about planes
example_assistant: {"setup": "Why don't planes ever get tired?", "punchline": "Because they have rest wings!", "rating": 2}

example_user: Tell me another joke about planes
example_assistant: {"setup": "Cargo", "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!", "rating": 10}

example_user: Now about caterpillars
example_assistant: {"setup": "Caterpillar", "punchline": "Caterpillar really slow, but watch me turn into a butterfly and steal the show!", "rating": 5}"""

# Create the prompt
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{input}")])

# Invoke the AI model with structured output
few_shot_structured_llm = prompt | structured_llm
result = few_shot_structured_llm.invoke("Tell me something funny about woodpeckers")

print(result)
```

### ✅ **Expected Output**
```json
{
  "setup": "Woodpecker",
  "punchline": "Woodpecker you a joke, but I'm afraid it might be too 'hole-some'!",
  "rating": 7
}
```
📌 **Explanation:**  
- The system message defines how the AI should respond by providing past examples.  
- The model learns the joke structure from the few-shot examples.  
- When we ask it for a joke about "woodpeckers," it follows the pattern and returns a structured response.  

---

# 🛠 **2. Few-Shot Prompting with Tool Calling**  

In some AI models, responses are structured using **tool calling**, meaning the AI generates tool calls instead of plain text. We can provide few-shot examples as **explicit tool calls** to guide the response.  

### 📜 **Code Example**
```python
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage

# Define few-shot examples using Tool Calls
examples = [
    HumanMessage("Tell me a joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Why don't planes ever get tired?",
                    "punchline": "Because they have rest wings!",
                    "rating": 2,
                },
                "id": "1",
            }
        ],
    ),
    ToolMessage("", tool_call_id="1"),
    HumanMessage("Tell me another joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Cargo",
                    "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!",
                    "rating": 10,
                },
                "id": "2",
            }
        ],
    ),
    ToolMessage("", tool_call_id="2"),
]

# Define the system prompt
system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke with a setup and punchline."""

prompt = ChatPromptTemplate.from_messages(
    [("system", system), ("placeholder", "{examples}"), ("human", "{input}")]
)

few_shot_structured_llm = prompt | structured_llm
result = few_shot_structured_llm.invoke({"input": "crocodiles", "examples": examples})

print(result)
```

### ✅ **Expected Output**
```json
{
  "setup": "Crocodile",
  "punchline": "Crocodile be seeing you later, alligator!",
  "rating": 6
}
```
📌 **Explanation:**  
- The AI uses **previously defined tool calls** to generate structured responses.  
- This method is useful when integrating AI with APIs or structured data systems.  
- The model recognizes patterns in past examples and adapts its output.  

---

# 🌎 **Real-World Applications of Few-Shot Prompting**  

Few-shot prompting is widely used in various fields to improve AI performance. Here are a few real-world applications:  

### 🎙️ **1. Chatbots & Virtual Assistants**  
🔹 AI assistants like **ChatGPT, Alexa, and Google Assistant** use few-shot prompting to generate responses in structured formats, ensuring consistency in answering FAQs or customer queries.  

### 🛍️ **2. E-commerce Product Descriptions**  
🔹 AI-powered e-commerce platforms use few-shot prompting to **generate structured product descriptions** based on past examples, ensuring a consistent tone and format.  

### 🏦 **3. Financial Data Extraction**  
🔹 In banking, AI models extract and format financial data (e.g., **loan applications, transaction summaries**) using few-shot prompting to maintain consistency and accuracy.  

### 🎨 **4. Creative Writing & Storytelling**  
🔹 AI tools like