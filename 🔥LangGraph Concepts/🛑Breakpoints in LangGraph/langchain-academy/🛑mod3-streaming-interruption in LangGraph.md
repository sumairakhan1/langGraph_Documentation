# 🚀 **Understanding Streaming in LangGraph (Beginner-Friendly Guide)**
---
## 🧩 **Introduction**
In this module, we explore **streaming** in LangGraph, a key concept that enables real-time interaction with graphs and chat models. By the end of this guide, you will:
- Understand **what streaming is** and how it works in LangGraph.
- Learn how to **implement streaming in a chatbot** using `LangChain` and `LangGraph`.
- Explore **real-world applications** of streaming.
- Get **step-by-step code explanations** for better understanding.

---
## 🌍 **Real-World Use Case of Streaming**
Streaming is commonly used in:
1. **Chatbots** (like ChatGPT or customer support bots) for **real-time responses**.
2. **Financial Dashboards** that update **stock prices live**.
3. **Live Sports Scores** displaying **real-time game updates**.
4. **AI-Powered Coding Assistants** (like GitHub Copilot) showing **real-time code suggestions**.

---
## 🔥 **What is Streaming in LangGraph?**
Streaming allows us to **visualize graph output in real-time**. In LangGraph, this means:
- We can **see tokens as they are generated** (instead of waiting for the whole response).
- The chatbot can **remember previous conversations** and **summarize them when needed**.
- Users can interact with the chatbot **without waiting for the full response**.

---
## 🚀 **Setting Up the Environment**
Before we start coding, we need to install the required libraries.

```python
%%capture --no-stderr
%pip install --quiet -U langgraph langchain_openai langgraph_sdk
```
🔹 **Explanation**:
- `pip install -U langgraph langchain_openai langgraph_sdk` → Updates the necessary Python packages.
- `%%capture --no-stderr` → Hides unnecessary output.

---
## 🔑 **Setting Up API Keys for OpenAI**
Since we are using OpenAI’s GPT-4 model, we need an **API Key**.

```python
import os, getpass

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("OPENAI_API_KEY")
```
🔹 **Explanation**:
- `os.environ.get(var)` → Checks if the API key is already set.
- `getpass.getpass(f"{var}: ")` → Securely prompts the user for an API key if it's missing.

---
## 🛠 **Setting Up LangChain and LangGraph**
Now, we define the necessary **import statements** and **graph components**.

```python
from IPython.display import Image, display
from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, RemoveMessage
from langchain_core.runnables import RunnableConfig
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START, END
from langgraph.graph import MessagesState
```
🔹 **Explanation**:
- `ChatOpenAI` → Creates a chatbot using OpenAI's GPT-4.
- `MessagesState` → Manages the chatbot’s memory.
- `StateGraph` → Creates a **graph-based workflow**.
- `START, END` → Define where our chatbot workflow starts and stops.

---
## 🧠 **Defining the Chatbot’s Memory State**
To keep track of **conversation history**, we define a **state class**.

```python
# LLM
model = ChatOpenAI(model="gpt-4o", temperature=0) 

# State
class State(MessagesState):
    summary: str
```
🔹 **Explanation**:
- `temperature=0` → Ensures **consistent** responses from GPT-4.
- `summary: str` → Stores a **summary of the conversation**.

---
## 🔄 **Calling the Chat Model**
We now define the function to interact with the **GPT-4 chatbot**.

```python
def call_model(state: State, config: RunnableConfig):
    
    # Get summary if it exists
    summary = state.get("summary", "")

    # If there is summary, then we add it
    if summary:
        system_message = f"Summary of conversation earlier: {summary}"
        messages = [SystemMessage(content=system_message)] + state["messages"]
    else:
        messages = state["messages"]

    response = model.invoke(messages, config)
    return {"messages": response}
```
🔹 **Explanation**:
- `state.get("summary", "")` → Fetches the **previous summary** (if any).
- If a summary exists, we **add it to the messages** so the chatbot remembers past interactions.
- `model.invoke(messages, config)` → Calls **GPT-4** to generate a response.

---
## ✍ **Summarizing Conversations for Memory**
To **summarize long conversations**, we use a helper function.

```python
def summarize_conversation(state: State):
    
    # First, we get any existing summary
    summary = state.get("summary", "")

    # Create our summarization prompt 
    if summary:
        summary_message = (
            f"This is summary of the conversation to date: {summary}\n\n"
            "Extend the summary by taking into account the new messages above:"
        )
    else:
        summary_message = "Create a summary of the conversation above:"

    # Add prompt to our history
    messages = state["messages"] + [HumanMessage(content=summary_message)]
    response = model.invoke(messages)
    
    # Delete all but the 2 most recent messages
    delete_messages = [RemoveMessage(id=m.id) for m in state["messages"][:-2]]
    return {"summary": response.content, "messages": delete_messages}
```
🔹 **Explanation**:
- If a **summary exists**, we extend it with the latest messages.
- Otherwise, we ask GPT-4 to **create a new summary**.
- `RemoveMessage(id=m.id) for m in state["messages"][:-2]` → Keeps only **the last two messages** for efficiency.

---
## ❓ **When Should the Chatbot Summarize?**
We define a function to decide **when to summarize the conversation**.

```python
def should_continue(state: State):
    
    """Return the next node to execute."""
    
    messages = state["messages"]
    
    # If there are more than six messages, then we summarize the conversation
    if len(messages) > 6:
        return "summarize_conversation"
    
    # Otherwise we can just end
    return END
```
🔹 **Explanation**:
- If **more than 6 messages** exist, we **trigger a summary**.
- Otherwise, we **end the conversation**.

---
## 🔗 **Building the Chatbot Graph**
Now, we create a **workflow graph** to connect all the components.

```python
# Define a new graph
workflow = StateGraph(State)
workflow.add_node("conversation", call_model)
workflow.add_node(summarize_conversation)

# Set the entrypoint as conversation
workflow.add_edge(START, "conversation")
workflow.add_conditional_edges("conversation", should_continue)
workflow.add_edge("summarize_conversation", END)

# Compile
memory = MemorySaver()
graph = workflow.compile(checkpointer=memory)
display(Image(graph.get_graph().draw_mermaid_png()))
```
🔹 **Explanation**:
- `StateGraph(State)` → Creates a **graph-based chatbot workflow**.
- `workflow.add_node("conversation", call_model)` → Calls GPT-4 when a user sends a message.
- `workflow.add_conditional_edges("conversation", should_continue)` → Decides **whether to continue or summarize**.
- `workflow.compile(checkpointer=memory)` → Saves **conversation history**.
- `display(Image(graph.get_graph().draw_mermaid_png()))` → **Visualizes the chatbot graph**.

---
## 🎯 **Key Takeaways**
✅ **Streaming** allows real-time **interaction with graphs**.  
✅ **Memory** enables chatbots to **remember previous conversations**.  
✅ **Summarization** helps maintain **long-running conversations efficiently**.  
✅ **Graph-based workflows** make chatbots **modular and scalable**.  

---
## 🎓 **Next Steps**
Now that you understand **streaming in LangGraph**, you can:
1. Try **modifying the chatbot** to support **different memory strategies**.
2. Implement **live streaming visualization** for **real-time token updates**.
3. Explore **integrating other AI models** like **Claude or Gemini**.

Would you like a follow-up guide on **visualizing token-wise streaming**? 🚀

---
# 🌐 **Streaming Full State in LangGraph**  

## 📌 **Introduction to Streaming in LangGraph**  
LangGraph provides a mechanism to stream back results while executing a conversation graph. It offers both **synchronous (`.stream`)** and **asynchronous (`.astream`)** methods to process and return data efficiently.  

This capability is useful in real-world applications like:  
✅ **Chatbots** that update responses dynamically  
✅ **Real-time dashboards** that display updates as they happen  
✅ **Monitoring systems** that track live state changes  

---

## 🚀 **Streaming Modes in LangGraph**  

LangGraph supports two primary modes for streaming graph states:  

1️⃣ **`values` Mode** – Streams the **entire state** of the graph after each node execution.  
2️⃣ **`updates` Mode** – Streams **only the changes** (updates) to the graph state after each node runs.  

| Streaming Mode  | What it Streams? | When to Use? |
|----------------|------------------|--------------|
| `values`  | Full graph state  | When you need the entire context after each node execution |
| `updates` | Only state updates | When you want incremental changes without redundant data |

### 📌 **Visual Representation**
The difference between `values` and `updates` can be visualized as:  

🔹 **Values mode:** Gives a complete snapshot after each step.  
🔹 **Updates mode:** Only provides **what changed** at each step.  

---

## 📝 **Example: Streaming with `updates` Mode**  

Here’s how we can stream **only state updates** in LangGraph:  

### **🔹 Step 1: Create a Conversation Thread**
We start by defining a **configuration** for the conversation thread.

```python
# Define a configuration for the thread
config = {"configurable": {"thread_id": "1"}}
```
- The `config` dictionary contains a `thread_id` to **uniquely identify** our conversation.  

### **🔹 Step 2: Start Streaming State Updates**
Now, we run a **conversation** and stream the updates as they occur.

```python
# Start a conversation and stream updates
for chunk in graph.stream(
    {"messages": [HumanMessage(content="hi! I'm Lance")]}, 
    config, 
    stream_mode="updates"
):
    print(chunk)
```
### **🧐 Explanation of Code:**
1️⃣ `graph.stream(...)` → Starts streaming the graph execution.  
2️⃣ `{"messages": [HumanMessage(content="hi! I'm Lance")]}` → Represents user input.  
3️⃣ `stream_mode="updates"` → Ensures only **state updates** are streamed.  
4️⃣ `print(chunk)` → Displays only **what changed** in the state.  

### **📌 Sample Output**  
```json
{
  "conversation": {
    "messages": AIMessage(content='Hi Lance! How can I assist you today?', 
    response_metadata={'total_tokens': 21})
  }
}
```
💡 **Notice:** We only receive the **update** (AI's response), not the entire conversation state.

---

## 📝 **Example: Streaming with `values` Mode**  

Now, let’s modify our example to stream **the full state** after each node execution.  

### **🔹 Step 1: Define a New Conversation Thread**
```python
# Define a new thread for this example
config = {"configurable": {"thread_id": "2"}}
```
🔹 We create a **new thread (`thread_id: "2"`)** for the next conversation session.

### **🔹 Step 2: Start Streaming Full State (`values` Mode)**
```python
# Start a conversation and stream full state values
input_message = HumanMessage(content="hi! I'm Lance")

for event in graph.stream(
    {"messages": [input_message]}, 
    config, 
    stream_mode="values"
):
    for m in event['messages']:
        m.pretty_print()
    print("---" * 25)
```

### **🧐 Explanation of Code:**
1️⃣ `stream_mode="values"` → Streams the **entire state** after each node execution.  
2️⃣ `for m in event['messages']:` → Loops through all messages in the state.  
3️⃣ `m.pretty_print()` → Displays messages in a **formatted way**.  
4️⃣ `print("---" * 25)` → Separates output for better readability.  

### **📌 Sample Output**  
```plaintext
================================ Human Message =================================
hi! I'm Lance
---------------------------------------------------------------------------
================================ Ai Message ==================================
Hi Lance! How can I assist you today?
---------------------------------------------------------------------------
```
💡 **Notice:** Here, we receive the **full conversation state**, including both the user input and AI response.

---

## 🎯 **Key Differences Between `values` and `updates` Modes**  

| Feature         | `values` Mode 🏷️ | `updates` Mode 🔄 |
|---------------|----------------|----------------|
| Data Streamed | Entire graph state | Only state changes |
| Data Size | Larger | Smaller |
| Use Case | When full history is needed | When tracking only changes |

---

## 📌 **Real-World Use Cases of Streaming Graph State**  

✅ **Live Chatbots:** AI assistants that dynamically respond to users while maintaining conversation history.  
✅ **Real-Time Monitoring:** Systems that continuously process updates (e.g., stock market, IoT devices).  
✅ **Customer Support AI:** Automated systems that assist customers based on conversation state.  
✅ **Workflow Execution:** Streaming updates of long-running processes (e.g., order processing).  

---

## 🏆 **Conclusion: When to Use `values` vs `updates`?**  
- Use **`values` mode** if you need **the full state after each step**.  
- Use **`updates` mode** if you want **just the changes** to minimize data transfer.  

🚀 **Mastering streaming state updates will help you build efficient, scalable, and real-time AI applications!**

---

# 🚀 **When to Use `values` vs. `updates` in LangGraph Streaming?**  

LangGraph provides two modes for streaming graph state:  
1️⃣ **`values` Mode** – Streams the full state after each step.  
2️⃣ **`updates` Mode** – Streams only the **changes** after each step.  

Understanding **when to use** each mode is **important** for optimizing performance and making the right design choice in your application. Let’s go deep into **where to use and where not to use each mode** with **real-world examples** and **scenarios**.

---

## 🔹 **Scenario 1: Building a Customer Support Chatbot**
💡 **Situation:**  
You are developing an **AI-powered chatbot** for a customer service website.  

✅ **Use `values` Mode (Full State Streaming)**  
- **Why?** You need to **keep track of the full conversation** history after every message.  
- **Example:** A chatbot assisting customers should remember past messages to give better responses.  

🔹 **Example Code:**
```python
config = {"configurable": {"thread_id": "support_1"}}

for event in graph.stream(
    {"messages": [HumanMessage(content="I need help with my order")]},
    config,
    stream_mode="values"
):
    for m in event['messages']:
        m.pretty_print()
    print("---" * 25)
```
**👀 Output:**  
```
================================ Human Message ================================
I need help with my order
---------------------------------------------------------------------------
================================ AI Message ==================================
Sure! Can you provide your order number?
---------------------------------------------------------------------------
```
🚀 **Why `values` mode?**  
- It keeps the full conversation history, which is crucial for **context-aware** chatbots.  

❌ **Do NOT use `updates` Mode**  
- Since `updates` only provides the latest message, it **loses the full conversation history**.

---

## 🔹 **Scenario 2: Real-Time Stock Market Updates**
💡 **Situation:**  
You are building a **stock market tracking system** that continuously updates **only the latest stock prices**.  

✅ **Use `updates` Mode (Incremental Updates)**  
- **Why?** You don’t need the full history of stock prices—just the **latest changes**.  
- **Example:** A stock ticker that displays only **new price changes** every second.  

🔹 **Example Code:**
```python
config = {"configurable": {"thread_id": "stock_market"}}

for chunk in graph.stream(
    {"stock_data": ["AAPL", "GOOGL", "TSLA"]}, 
    config, 
    stream_mode="updates"
):
    print(chunk)
```
**👀 Output:**  
```json
{"AAPL": "Price updated: $175.32"}
{"TSLA": "Price updated: $665.50"}
{"GOOGL": "Price updated: $2800.40"}
```
🚀 **Why `updates` mode?**  
- It **only** sends **the latest stock price** instead of the entire price history.  
- It is **faster and more efficient** because it doesn’t send unnecessary data.  

❌ **Do NOT use `values` Mode**  
- **Unnecessary data transfer** → You don’t need the full stock price history every second.  

---

## 🔹 **Scenario 3: Live Transcription System (Captions for Videos)**
💡 **Situation:**  
You are creating a **live subtitle system** that transcribes speech in **real time** for videos or meetings.  

✅ **Use `updates` Mode (Incremental Updates)**  
- **Why?** You only want **new words** to appear on the screen instead of retransmitting the entire conversation.  
- **Example:** A **YouTube Live transcription system** that updates captions word by word.  

🔹 **Example Code:**
```python
config = {"configurable": {"thread_id": "live_transcription"}}

for chunk in graph.stream(
    {"audio": "Live speech input"}, 
    config, 
    stream_mode="updates"
):
    print(chunk)
```
**👀 Output:**  
```json
{"transcription": "Hello, everyone!"}
{"transcription": "Welcome to our event."}
```
🚀 **Why `updates` mode?**  
- **Efficient:** It only streams **new words**, preventing redundant data.  
- **Fast:** Makes live captions **appear instantly** instead of waiting for the entire sentence.  

❌ **Do NOT use `values` Mode**  
- It would **retransmit** the full conversation every time, making captions **slow and inefficient**.

---

## 🔹 **Scenario 4: Workflow Execution Monitoring**
💡 **Situation:**  
You are building a **workflow automation system** that executes multiple tasks sequentially.  

✅ **Use `values` Mode (Full State Streaming)**  
- **Why?** You need to **track all completed steps** at each stage.  
- **Example:** A **bank loan approval system** that goes through multiple checks before approval.  

🔹 **Example Code:**
```python
config = {"configurable": {"thread_id": "loan_process"}}

for event in graph.stream(
    {"loan_application": "12345"}, 
    config, 
    stream_mode="values"
):
    for m in event['workflow_steps']:
        print(m)
```
**👀 Output:**  
```
Loan Application Received ✅
Credit Check Completed ✅
Loan Approved ✅
```
🚀 **Why `values` mode?**  
- It keeps track of **all completed workflow steps**.  
- Users can see the **full history** of what has happened so far.  

❌ **Do NOT use `updates` Mode**  
- It would only show the **latest step**, making it hard to track the full process.

---

## 🔥 **Comparison Table: When to Use `values` vs. `updates` Mode**  

| Use Case | ✅ Use `values` Mode (Full State) | ✅ Use `updates` Mode (Only Changes) |
|----------|--------------------------------|--------------------------------|
| 🤖 Chatbot (with history) | ✅ | ❌ |
| 📈 Stock Market Updates | ❌ | ✅ |
| 🎤 Live Transcriptions | ❌ | ✅ |
| 🏦 Loan Approval Workflow | ✅ | ❌ |
| 🚀 Real-Time Sensor Monitoring | ❌ | ✅ |
| 📊 Data Dashboard (Historical Data) | ✅ | ❌ |

---

## 🎯 **Final Summary: Which Mode Should You Use?**
| **Scenario** | **Mode to Use** | **Why?** |
|-------------|---------------|---------|
| **Keeping full history** (e.g., chatbots, workflows) | `values` | Keeps track of **all past interactions** |
| **Live data updates** (e.g., stock prices, live captions) | `updates` | Sends **only the latest changes**, avoiding redundancy |
| **Event-driven systems** (e.g., IoT monitoring) | `updates` | Streams **real-time changes** without old data |
| **Tracking completed steps** (e.g., approval processes) | `values` | Stores **entire progress history** |

---

## 🏆 **Conclusion: Making the Right Choice**
- Use **`values` mode** when **you need the full state** at each step.  
- Use **`updates` mode** when **you only need new changes** and want **faster, efficient updates**.  

💡 **By choosing the right mode, you can build faster and smarter real-time applications! 🚀**

---

# 🟢 **Streaming Tokens in AI Chat Models**  

Streaming tokens is a technique used to receive and process AI-generated responses in real time instead of waiting for the entire response to be completed. This is particularly useful in chat applications, real-time AI interactions, and dynamic content generation.

---

## 🔥 **Why Use Streaming Tokens?**
1. **Real-time User Experience:** Enhances responsiveness by showing words as they are generated.
2. **Efficient Processing:** Allows early processing of tokens without waiting for the full response.
3. **Better User Engagement:** Makes conversations feel more natural and interactive.

---

# 📌 **Understanding `astream_events` Method**
The `.astream_events()` method is used to stream events as they occur inside nodes in an AI model. Each event contains useful information:

| 🔹 Key         | 🔹 Description |
|---------------|--------------|
| `event`      | The type of event being emitted (e.g., `on_chat_model_stream`) |
| `name`       | The name of the event |
| `data`       | The actual response content from the AI model |
| `metadata`   | Extra information, including `langgraph_node` (node emitting the event) |

---

## 🏗 **Example: Streaming AI Chat Responses**
### 🛠 **Step-by-Step Code Breakdown**
```python
config = {"configurable": {"thread_id": "3"}}
input_message = HumanMessage(content="Tell me about the 49ers NFL team")

async for event in graph.astream_events({"messages": [input_message]}, config, version="v2"):
    print(f"Node: {event['metadata'].get('langgraph_node','')}. Type: {event['event']}. Name: {event['name']}")
```

### ✅ **Explanation of Code**
1. **Define Configuration:**
   ```python
   config = {"configurable": {"thread_id": "3"}}
   ```
   - This sets up the conversation thread with an ID (`thread_id: 3`).

2. **Create Input Message:**
   ```python
   input_message = HumanMessage(content="Tell me about the 49ers NFL team")
   ```
   - A message is created that asks the AI about the 49ers football team.

3. **Start Streaming Events:**
   ```python
   async for event in graph.astream_events({"messages": [input_message]}, config, version="v2"):
   ```
   - Calls `.astream_events()` to stream events from the AI model.

4. **Extract & Print Event Details:**
   ```python
   print(f"Node: {event['metadata'].get('langgraph_node','')}. Type: {event['event']}. Name: {event['name']}")
   ```
   - Displays which node emitted the event, its type, and name.

---

## 🔥 **Extracting Chat Model Tokens**
We can filter the events to extract only chat-related tokens.

### ✨ **Modified Code Example**
```python
node_to_stream = 'conversation'
config = {"configurable": {"thread_id": "4"}}
input_message = HumanMessage(content="Tell me about the 49ers NFL team")

async for event in graph.astream_events({"messages": [input_message]}, config, version="v2"):
    if event["event"] == "on_chat_model_stream" and event['metadata'].get('langgraph_node','') == node_to_stream:
        print(event["data"])
```

### ✅ **Explanation of Code**
1. **Filter Specific Node:**
   ```python
   node_to_stream = 'conversation'
   ```
   - We specify a node that we want to stream from.

2. **Stream Only Chat Model Tokens:**
   ```python
   if event["event"] == "on_chat_model_stream" and event['metadata'].get('langgraph_node','') == node_to_stream:
   ```
   - Checks if the event is `on_chat_model_stream` and belongs to the `conversation` node.

3. **Print Token Data:**
   ```python
   print(event["data"])
   ```
   - Displays AI response tokens in chunks.

---

## 🏆 **Real-World Use Cases of Streaming Tokens**
| 📌 Use Case | 🎯 How Streaming Helps |
|------------|----------------------|
| **Chatbots** | Provides a smooth real-time chat experience |
| **Live Transcription** | Streams words as they are recognized by speech-to-text models |
| **Code Assistants** | AI-powered code suggestions appear instantly |
| **AI-Powered Search** | Streams search results as they are generated |

---

## 🔄 **Alternative Approaches**
Here are three alternative ways to implement streaming.

### 🔹 **1. Using OpenAI's Streaming API**
If using OpenAI's `openai.ChatCompletion.create` with `stream=True`:
```python
import openai

response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Tell me about the 49ers NFL team"}],
    stream=True
)

for chunk in response:
    if chunk["choices"][0]["delta"]:
        print(chunk["choices"][0]["delta"]["content"], end="")
```
✅ **Key Difference:** Uses OpenAI’s built-in streaming for direct API interaction.

---

### 🔹 **2. Using WebSockets for Streaming**
If implementing a chatbot with WebSockets:
```python
import asyncio
import websockets

async def chat():
    async with websockets.connect("wss://your-ai-server.com/chat") as ws:
        await ws.send("Tell me about the 49ers NFL team")
        while True:
            response = await ws.recv()
            print(response, end=" ")

asyncio.run(chat())
```
✅ **Key Difference:** Uses WebSockets for continuous streaming from an AI server.

---

### 🔹 **3. Using FastAPI for Streaming in Web Apps**
If you want to integrate token streaming in a FastAPI server:
```python
from fastapi import FastAPI
from starlette.responses import StreamingResponse
import asyncio

app = FastAPI()

async def generate_stream():
    tokens = ["The", " San", " Francisco", " 49ers", " are", " a", " professional", " football", " team."]
    for token in tokens:
        yield token
        await asyncio.sleep(0.2)  # Simulate delay

@app.get("/stream")
async def stream():
    return StreamingResponse(generate_stream(), media_type="text/plain")
```
✅ **Key Difference:** Streams responses via an API endpoint.

---

## 🚀 **Final Thoughts**
- **Use `.astream_events()`** when working with AI models that provide real-time token generation.
- **Filter events** to extract only relevant responses.
- **Consider alternative approaches** like OpenAI’s API, WebSockets, or FastAPI for different scenarios.

Would you like a hands-on project where we implement streaming in a chatbot? 🚀

---

# 🚀 **Streaming with LangGraph API**  

Streaming allows us to receive data in real time as it becomes available, rather than waiting for a full response. In the **LangGraph API**, we can use **streaming** to retrieve values, messages, and metadata efficiently.

---

## 🔥 **What is Streaming in LangGraph?**
Streaming in **LangGraph** allows us to continuously receive **tokens** or **data chunks** from a chat model or an agent. This is useful when working with **AI-generated content, real-time applications, and chatbot interactions**.

### 📌 **Why Use Streaming?**
- ✅ **Faster Responses** – Get data in real-time without waiting for full completion.
- ✅ **Better User Experience** – Users see responses appearing gradually, like a real conversation.
- ✅ **Efficient Resource Utilization** – Processes data as it arrives instead of waiting.

---

## 📍 **Key Components in LangGraph Streaming**  
Each streaming event contains the following:

🔹 **`event`** → Type of event (e.g., `metadata`, `messages/partial`)  
🔹 **`data`** → Data associated with the event (e.g., message content)  

🔹 **`metadata`** → Information about the node emitting the event  

---

## 🔷 **Example 1: Basic Streaming with LangGraph**
### **📌 Setup LangGraph Client and Stream Data**
Below is a **Python** example demonstrating **LangGraph Streaming**:

### **🔹 Step 1: Import Required Libraries**
```python
import platform
from langgraph_sdk import get_client
from langchain_core.messages import HumanMessage
import asyncio
```
- 📌 `platform`: Checks the operating system (Mac, Windows, etc.).
- 📌 `get_client`: Gets the LangGraph API client.
- 📌 `HumanMessage`: Represents a human-generated message.
- 📌 `asyncio`: Used for asynchronous streaming.

---

### **🔹 Step 2: Check for Compatible OS**
```python
if 'google.colab' in str(get_ipython()) or platform.system() != 'Darwin':
    raise Exception("Unfortunately, LangGraph Studio is currently not supported on Google Colab or requires a Mac")
```
- ✅ Ensures compatibility (LangGraph Studio works only on **Mac**).
- ✅ Raises an error if **Google Colab** or **non-Mac OS** is detected.

---

### **🔹 Step 3: Connect to LangGraph API**
```python
# Replace with your LangGraph API URL
URL = "http://localhost:56091"
client = get_client(url=URL)
```
- ✅ Connects to **LangGraph API** using a **local server URL**.
- ✅ `client` is used to interact with the LangGraph API.

---

### **🔹 Step 4: Create a New Thread**
```python
thread = await client.threads.create()
```
- ✅ Creates a new **thread** for managing conversations.

---

### **🔹 Step 5: Stream Messages in Real-Time**
```python
# Define a user message
input_message = HumanMessage(content="Multiply 2 and 3")

# Stream messages in real-time
async for event in client.runs.stream(
    thread["thread_id"], 
    assistant_id="agent", 
    input={"messages": [input_message]}, 
    stream_mode="values"
):
    print(event)
```
- ✅ Sends a **message** (`Multiply 2 and 3`) to the assistant.
- ✅ **Streams** the response **in real-time**.
- ✅ Each `event` represents a **part** of the streamed response.

---

### **🔷 Output (Example)**
```
StreamPart(event='metadata', data={'run_id': '1ef6a3d0-41eb-66f4-a311-8ebdfa1b281f'})
StreamPart(event='values', data={'messages': [{'content': 'Multiply 2 and 3', 'type': 'human'}]})
```
- ✅ The first response is **metadata** (Run ID).
- ✅ The second response contains **messages**.

---

## 🔷 **Example 2: Extracting Messages from Streaming**
Instead of printing raw data, we can extract **only the messages**:

```python
from langchain_core.messages import convert_to_messages

thread = await client.threads.create()
input_message = HumanMessage(content="Multiply 2 and 3")

async for event in client.runs.stream(
    thread["thread_id"], 
    assistant_id="agent", 
    input={"messages": [input_message]}, 
    stream_mode="values"
):
    messages = event.data.get('messages', None)
    if messages:
        print(convert_to_messages(messages)[-1])  # Display last message
    print('=' * 25)
```

### **🔷 Output**
```
=========================
content='Multiply 2 and 3'
=========================
content='' tool_calls=[{'name': 'multiply', 'args': {'a': 2, 'b': 3}}]
=========================
content='6'
=========================
```
- ✅ First message: **User input ("Multiply 2 and 3")**.
- ✅ Second message: **Function call to "multiply"**.
- ✅ Third message: **Final result ("6")**.

---

## 🌍 **Real-World Use Cases of Streaming in LangGraph**
📌 **Chatbots & Virtual Assistants** – Generate AI responses in real-time.  
📌 **Stock Market Feeds** – Stream live **stock price updates**.  
📌 **Sports Updates** – Get real-time **match scores & statistics**.  
📌 **Live Transcription** – Convert **speech to text** in **real-time**.  

---

## 🎯 **Alternative Examples for Strong Understanding**
### **🔹 Alternative 1: Streaming for AI Assistant**
```python
input_message = HumanMessage(content="What is the capital of France?")
async for event in client.runs.stream(thread["thread_id"], assistant_id="agent", input={"messages": [input_message]}, stream_mode="messages"):
    print(event.event)
```
🔹 **Output:**  
```
metadata
messages/complete
messages/metadata
messages/partial
```

---

### **🔹 Alternative 2: Streaming Live Weather Updates**
```python
input_message = HumanMessage(content="What's the weather in New York?")
async for event in client.runs.stream(thread["thread_id"], assistant_id="weather_bot", input={"messages": [input_message]}, stream_mode="values"):
    print(event)
```
🔹 **Output:**  
```
Current temperature: 72°F
Humidity: 60%
```

---

### **🔹 Alternative 3: Streaming API Logs for Debugging**
```python
async for event in client.runs.stream(thread["thread_id"], assistant_id="debugger", input={"messages": []}, stream_mode="messages"):
    print(f"Event: {event.event} - Data: {event.data}")
```
🔹 **Output:**  
```
Event: metadata - Data: {'run_id': 'abc123'}
Event: messages/partial - Data: {'message': 'Processing...'}
```

---

## 🔥 **Summary**
✅ **Streaming** allows real-time data flow in **LangGraph**.  
✅ **Events & Data** help extract useful information.  
✅ **Practical Applications** include **chatbots, live updates, AI assistants, and debugging**.  
✅ **Different Streaming Modes** (`values`, `messages`) control how we retrieve data.  

Would you like additional explanations or a custom example? 😊 🚀

---
# 🚀 **Streaming with LangGraph API – A Beginner-Friendly Guide**  

The **LangGraph API** enables real-time streaming of responses and interactions between users and AI agents. This is especially useful in applications like **chatbots, real-time AI assistants, and live analytics dashboards**.  

Let’s break down **streaming with LangGraph API**, explaining each part of the process in a simple, detailed, and beginner-friendly manner.  

---

## 📌 **What is Streaming in LangGraph API?**  
Streaming is a technique where **data is continuously transmitted** instead of waiting for the entire response to be ready. This is commonly used in:  

✅ **Live chat applications** (e.g., ChatGPT, customer support bots)  
✅ **Real-time analytics** (e.g., financial trading platforms)  
✅ **Voice assistants** (e.g., Alexa, Siri)  

LangGraph API allows **streaming AI responses in parts**, making interactions **faster and more efficient**.  

---

## 🛠 **Setting Up the LangGraph Client**  
Before we begin, let's set up our **LangGraph API client** to interact with the backend.

### **🔹 Step 1: Import Required Libraries**
```python
import platform

# Check if the environment supports LangGraph Studio
if 'google.colab' in str(get_ipython()) or platform.system() != 'Darwin':
    raise Exception("Unfortunately, LangGraph Studio is currently not supported on Google Colab or requires a Mac")

# Import the LangGraph SDK
from langgraph_sdk import get_client

# Set up the API client with the server URL
URL = "http://localhost:56091"  # Replace with your actual LangGraph server URL
client = get_client(url=URL)
```
### 🔍 **Explanation**:
- **`platform.system()`** → Checks if the system is a Mac (`Darwin`), as **LangGraph Studio only supports Mac**.
- **`get_client(url=URL)`** → Creates a connection to the LangGraph server.
- **`raise Exception()`** → Prevents execution if running in an unsupported environment.

---

## 📝 **Streaming Responses from the AI Assistant**  

We will **send a user query** to the AI assistant and stream its response in real-time.

### **🔹 Step 2: Search for Available Assistants**
```python
# Fetch all available AI assistants hosted on the LangGraph server
assistants = await client.assistants.search()
```
### 🔍 **Explanation**:
- **`client.assistants.search()`** → Fetches all **available AI assistants** from the LangGraph API.
- Useful if you **host multiple AI agents** and want to select the right one.

---

### **🔹 Step 3: Create a Thread for the Conversation**
```python
# Create a new chat thread
thread = await client.threads.create()
```
### 🔍 **Explanation**:
- **A thread** represents a **chat session**.  
- Every message in LangGraph is part of a **thread**, allowing AI to **maintain context**.

---

### **🔹 Step 4: Send a Message and Stream the Response**
```python
# Create a user message
input_message = HumanMessage(content="Multiply 2 and 3")

# Stream AI responses
async for event in client.runs.stream(
    thread["thread_id"],
    assistant_id="agent",
    input={"messages": [input_message]},
    stream_mode="messages",
):
    print(event)
```
### 🔍 **Explanation**:
- **Creates a user message (`HumanMessage(content="Multiply 2 and 3")`)**  
- **Streams the assistant’s response** using `client.runs.stream()`.  
- The response is received **in chunks** instead of waiting for the entire reply.  

---

## 📡 **Understanding Streamed Data (Events & Messages)**  

LangGraph **streams data in parts**, which means different types of events will arrive.  

### 📌 **Key Event Types**:
| Event Type         | Purpose |
|--------------------|---------|
| **metadata**       | Information about the request (e.g., Run ID) |
| **messages/partial** | AI-generated responses arriving in chunks (tokens) |
| **messages/complete** | Fully formed AI response |

---

## 📢 **Handling and Formatting AI Responses**
AI messages sometimes include **tool calls** (e.g., calling a calculator function).  
Let’s **format** these tool calls into a **readable** format.

### **🔹 Step 5: Define a Helper Function to Format Tool Calls**
```python
def format_tool_calls(tool_calls):
    """
    Format a list of tool calls into a readable string.

    Args:
        tool_calls (list): A list of dictionaries, each representing a tool call.

    Returns:
        str: A formatted string of tool calls, or "No tool calls" if the list is empty.
    """

    if tool_calls:
        formatted_calls = []
        for call in tool_calls:
            formatted_calls.append(
                f"Tool Call ID: {call['id']}, Function: {call['name']}, Arguments: {call['args']}"
            )
        return "\n".join(formatted_calls)
    return "No tool calls"
```
### 🔍 **Explanation**:
- **Takes a list of tool calls** and extracts useful details like `function name`, `arguments`, and `ID`.
- **Returns a formatted string** for easy reading.

---

### **🔹 Step 6: Handle Streamed Events and Process Responses**
```python
async for event in client.runs.stream(
    thread["thread_id"],
    assistant_id="agent",
    input={"messages": [input_message]},
    stream_mode="messages",
):
    # Handle metadata events
    if event.event == "metadata":
        print(f"Metadata: Run ID - {event.data['run_id']}")
        print("-" * 50)

    # Handle partial message events
    elif event.event == "messages/partial":
        for data_item in event.data:
            # Process user messages
            if "role" in data_item and data_item["role"] == "user":
                print(f"Human: {data_item['content']}")
            else:
                # Extract relevant data from the event
                tool_calls = data_item.get("tool_calls", [])
                invalid_tool_calls = data_item.get("invalid_tool_calls", [])
                content = data_item.get("content", "")
                response_metadata = data_item.get("response_metadata", {})

                if content:
                    print(f"AI: {content}")

                if tool_calls:
                    print("Tool Calls:")
                    print(format_tool_calls(tool_calls))

                if invalid_tool_calls:
                    print("Invalid Tool Calls:")
                    print(format_tool_calls(invalid_tool_calls))

                if response_metadata:
                    finish_reason = response_metadata.get("finish_reason", "N/A")
                    print(f"Response Metadata: Finish Reason - {finish_reason}")
                    
        print("-" * 50)
```
### 🔍 **Explanation**:
- **Checks the type of event** (`metadata`, `messages/partial`, etc.).
- **Prints human messages and AI responses** in real-time.
- **Formats tool calls** for easy readability.
- **Extracts metadata** (e.g., why AI stopped responding).

---

## 🌍 **Real-World Applications of LangGraph Streaming**
| Application | Use Case |
|------------|----------|
| **AI Chatbots** | Streaming responses in real-time (e.g., customer support) |
| **Live Transcription** | AI-powered transcription of spoken words (e.g., YouTube subtitles) |
| **Stock Market Analytics** | Real-time price analysis (e.g., financial trading bots) |
| **Voice Assistants** | Alexa/Siri-style real-time interactions |

---

## 🏆 **Key Takeaways**
✅ **LangGraph API supports real-time AI streaming.**  
✅ **Different event types (metadata, messages/partial, etc.) provide structured data.**  
✅ **Tool calls can be formatted for better understanding.**  
✅ **Streaming is used in AI assistants, chatbots, finance, and more.**  

---

## 🎯 **Alternative Approaches**
1️⃣ **Use REST API instead of streaming** if real-time responses are not required.  
2️⃣ **Cache AI responses** to reduce redundant processing in repeated queries.  
3️⃣ **Use WebSockets** for bidirectional communication between AI and users.  

---

This guide covers **everything a beginner needs to understand LangGraph streaming!** 🚀  

Would you like a **real-world example** of integrating LangGraph into a chatbot? Let me know! 😊