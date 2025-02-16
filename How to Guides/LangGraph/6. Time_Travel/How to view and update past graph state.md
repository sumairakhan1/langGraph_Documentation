# How to view and update past graph state

# 🕰️ Time Travel in LangGraph: A Beginner's Guide  

## 🔍 Introduction  
Time travel in **LangGraph** allows developers to revisit past actions, debug issues, and explore alternative execution paths in their applications. This guide explains **how to view and update past graph states** using time travel.  

---

## 🎯 **Why Use Time Travel in LangGraph?**  
Time travel is useful for:  
✅ **Debugging** – Rewind the graph to reproduce or fix errors.  
✅ **User Interaction** – Present users with a state during an interrupt for decision-making.  
✅ **State Modification** – Embed your agent in a larger system or allow better control.  

The **key methods** used for time travel are:  
- `get_state`: Fetches values from a target configuration.  
- `update_state`: Applies updated values to the state.  

> **⚠️ Note:** Time travel requires a **checkpointer** to store and retrieve states.  

---

## 🛠 **Setting Up the Environment**  
Before we begin, we need to install the necessary dependencies.  

### 📌 Install Required Packages  
```python
%%capture --no-stderr
%pip install --quiet -U langgraph langchain_openai
```
This command installs **LangGraph** and **LangChain OpenAI**, which are essential for building our agent.

### 🔑 **Set Up API Keys**  
We need API keys to interact with OpenAI's models.  
```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

_set_env("OPENAI_API_KEY")  # Prompt for API key
```
**🔍 Explanation:**  
- `getpass.getpass()` prompts the user for the API key securely.  
- The key is stored in the `os.environ` variable to be accessed by the application.  

---

## 🤖 **Building the Agent**  
Now, let's build a **ReAct-style agent** that interacts with different music platforms (Spotify and Apple Music).  

### 🎵 **Define Tools for Music Playback**  
```python
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from langgraph.graph import MessagesState, START, END, StateGraph
from langgraph.prebuilt import ToolNode
from langgraph.checkpoint.memory import MemorySaver

@tool
def play_song_on_spotify(song: str):
    """Play a song on Spotify"""
    return f"Successfully played {song} on Spotify!"

@tool
def play_song_on_apple(song: str):
    """Play a song on Apple Music"""
    return f"Successfully played {song} on Apple Music!"
```
**🔍 Explanation:**  
- We define two **tools** (`play_song_on_spotify` and `play_song_on_apple`) to simulate playing a song on different platforms.  
- The `@tool` decorator marks these functions as callable by the agent.  
- **Return values** confirm the song has been played.  

### 🛠 **Register Tools**  
```python
tools = [play_song_on_apple, play_song_on_spotify]
tool_node = ToolNode(tools)
```
**🔍 Explanation:**  
- We **group the tools** in a list.  
- `ToolNode(tools)` registers them as callable tools in LangGraph.  

---

## 🧠 **Setting Up the AI Model**  
```python
model = ChatOpenAI(model="gpt-4o-mini")
model = model.bind_tools(tools, parallel_tool_calls=False)
```
**🔍 Explanation:**  
- `ChatOpenAI(model="gpt-4o-mini")` initializes the **GPT-4o-mini** model for chat responses.  
- `bind_tools(tools, parallel_tool_calls=False)` links the **Spotify and Apple Music tools** to the model.  

---

## 🔄 **Creating the Decision Logic**  

### 🏗 **Define Decision Function**  
```python
def should_continue(state):
    messages = state["messages"]
    last_message = messages[-1]
    
    if not last_message.tool_calls:
        return "end"
    else:
        return "continue"
```
**🔍 Explanation:**  
- This function **decides whether to continue** or stop execution based on the last message.  
- If the message **does not call a tool**, the process **ends**.  
- Otherwise, execution **continues**.  

### 🏗 **Define Model Invocation Function**  
```python
def call_model(state):
    messages = state["messages"]
    response = model.invoke(messages)
    return {"messages": [response]}
```
**🔍 Explanation:**  
- This function **invokes the model** with the current messages.  
- The **response** is returned as a **list** to be added to the conversation history.  

---

## 🔗 **Building the LangGraph Workflow**  
### 📌 **Initialize the Graph**  
```python
workflow = StateGraph(MessagesState)
```
This initializes a **stateful graph** to manage messages.  

### 📌 **Add Nodes**  
```python
workflow.add_node("agent", call_model)
workflow.add_node("action", tool_node)
```
**🔍 Explanation:**  
- `"agent"`: Calls the **model** to process messages.  
- `"action"`: Calls the **tool node** to execute actions (playing music).  

### 📌 **Define Execution Flow**  
```python
workflow.add_edge(START, "agent")
```
This sets `"agent"` as the **starting node**.  

```python
workflow.add_conditional_edges(
    "agent",
    should_continue,
    {
        "continue": "action",
        "end": END,
    },
)
```
**🔍 Explanation:**  
- **After the agent node executes**, `should_continue()` decides the next step:  
  - `"continue"` → Call the **tool node**.  
  - `"end"` → Stop execution.  

```python
workflow.add_edge("action", "agent")
```
This **creates a loop**, allowing the agent to execute multiple actions.  

---

## 💾 **Adding Time Travel Functionality**  
```python
memory = MemorySaver()
app = workflow.compile(checkpointer=memory)
```
**🔍 Explanation:**  
- `MemorySaver()` is used for **saving checkpoints** (time travel state).  
- `workflow.compile(checkpointer=memory)` enables **time travel debugging**.  

> **✅ Now, we can rewind, debug, and modify graph states!**  

---

## 🏆 **Real-World Use Case**  
Imagine an **AI-powered music assistant** that helps users play songs via chat commands. Time travel allows:  
- **Debugging failed song requests** by revisiting past states.  
- **User confirmation** before playing a song.  
- **Handling interruptions** by letting users resume actions later.  

---

## 🎯 **Key Takeaways**  
✅ **Time Travel in LangGraph** enables **state retrieval and modification**.  
✅ **StateGraph** organizes decision-making with **conditional logic**.  
✅ **Checkpoints** allow debugging and alternative execution paths.  
✅ **Practical use case**: AI assistants, automation bots, and more.  

🚀 **Now you’re ready to build AI-powered workflows with Time Travel!**

---

It looks like you want a deep and beginner-friendly explanation of how interacting with an AI agent works, particularly using LangChain. I'll break this down into sections with detailed explanations, real-world applications, and line-by-line code explanations. 

---

# 🧠 Understanding AI Agent Interaction with LangChain

LangChain allows us to build AI agents that can interact with users, call tools (like playing music), and maintain conversation history. This is particularly useful for chatbots, virtual assistants, and AI-driven applications.

---

## 🚀 **What is an AI Agent?**
An **AI Agent** is a program that can:
- Understand user input
- Decide what actions to take
- Call external tools (like a music player)
- Respond intelligently based on context

### **🛠 Real-World Applications**
- **Voice Assistants** (Siri, Google Assistant)
- **Customer Support Bots** (Handling FAQs, directing users)
- **Smart Home Automation** (Controlling lights, music)
- **AI-based Personal Assistants** (Scheduling, reminders)

---

## 🔥 **How AI Agents Work in LangChain**
LangChain provides `HumanMessage` and `AIMessage` objects to manage conversations. These messages are processed, and if needed, external tools (like a music player) are invoked.

### **👨‍💻 Code Implementation: AI Agent Playing a Song**
Let's go through the code step by step:

```python
from langchain_core.messages import HumanMessage

# Configuration settings for the conversation (assigning a unique thread ID)
config = {"configurable": {"thread_id": "1"}}

# Creating a human message (User asking to play Taylor Swift's most popular song)
input_message = HumanMessage(content="Can you play Taylor Swift's most popular song?")

# Processing the request and streaming the response
for event in app.stream({"messages": [input_message]}, config, stream_mode="values"):
    event["messages"][-1].pretty_print()
```

### **📝 Code Explanation**
1. **`from langchain_core.messages import HumanMessage`**  
   - Imports `HumanMessage`, which represents a message sent by the user.
  
2. **`config = {"configurable": {"thread_id": "1"}}`**  
   - Assigns a unique thread ID (`thread_id: "1"`) to track this conversation.

3. **`input_message = HumanMessage(content="Can you play Taylor Swift's most popular song?")`**  
   - Creates a `HumanMessage` object containing the user's request.

4. **`for event in app.stream({"messages": [input_message]}, config, stream_mode="values"):`**  
   - Passes the message to the AI agent and streams the response.

5. **`event["messages"][-1].pretty_print()`**  
   - Retrieves and prints the latest AI-generated response.

---

## 🎵 **How the AI Agent Calls an External Tool (Music Player)**
When the user asks to play a song, the AI does two things:
1. **Understands the request** ("Play Taylor Swift's most popular song").
2. **Calls an external tool** to play the song.

This is represented in the output:
```plaintext
================================== Ai Message ==================================
Tool Calls:
  play_song_on_apple (call_uhGY6Fv6Mr4ZOhSokintuoD7)
  Args:
    song: Anti-Hero by Taylor Swift
================================== Tool Message ==================================
Name: play_song_on_apple
Succesfully played Anti-Hero by Taylor Swift on Apple Music!
```

### **📝 Explanation**
- **`play_song_on_apple`**  
  - This function is called to play the song on Apple Music.
- **`song: Anti-Hero by Taylor Swift`**  
  - The AI determined that the most popular Taylor Swift song is "Anti-Hero" and passed this as an argument.
- **`Successfully played Anti-Hero by Taylor Swift on Apple Music!`**  
  - The tool executes successfully, and the response confirms that the song was played.

---

## 📜 **Checking Conversation History**
LangChain allows us to track conversation history using `app.get_state(config).values["messages"]`.

```python
app.get_state(config).values["messages"]
```

### **📝 Example Output**
```plaintext
[HumanMessage(content="Can you play Taylor Swift's most popular song?"),
 AIMessage(content='I\'ve successfully played "Anti-Hero" by Taylor Swift on Apple Music! Enjoy the music!')]
```

### **🔍 Why is this Useful?**
- Maintains a record of previous interactions.
- Helps in building context-aware conversations.
- Useful for debugging AI responses.

---

## 🏆 **Final Thoughts**
- **LangChain makes AI interactions simple and efficient.**
- **AI Agents can call external tools to execute real-world tasks.**
- **Keeping conversation history allows for better responses.**

Would you like me to extend this to cover more advanced AI agent functionalities, such as integrating with multiple tools? 🚀

---

# 🤖 Interacting with the Agent: A Detailed Beginner’s Guide

In this section, we'll learn how to interact with a LangGraph agent. We’ll cover how to send a message to the agent, stream its response, and review the history of interactions. This is especially useful for understanding the flow of your application and debugging its behavior.

---

## 🎯 What Are We Doing?

1. **Sending a Message:**  
   We create a human message (a user query) asking the agent to play Taylor Swift's most popular song.

2. **Streaming the Response:**  
   The agent processes the message, potentially calling a tool (in our example, a simulated music player), and then streams back responses in real-time.

3. **Checking the Interaction History:**  
   We can review the entire conversation history (all the states) to understand the execution flow and debug if necessary.

---

## 💻 Code Example & Line-by-Line Explanation

### 1. Sending a Message to the Agent

```python
from langchain_core.messages import HumanMessage

# Set up a configuration for the interaction.
config = {"configurable": {"thread_id": "1"}}

# Create a human message with the content asking to play Taylor Swift's most popular song.
input_message = HumanMessage(content="Can you play Taylor Swift's most popular song?")

# Stream the response from the agent.
for event in app.stream({"messages": [input_message]}, config, stream_mode="values"):
    event["messages"][-1].pretty_print()
```

**Explanation:**

- **Importing the HumanMessage Class:**  
  ```python
  from langchain_core.messages import HumanMessage
  ```  
  This line imports the `HumanMessage` class, which is used to create a message object representing what a user might say.

- **Setting Up the Configuration:**  
  ```python
  config = {"configurable": {"thread_id": "1"}}
  ```  
  Here, we define a configuration dictionary. The `"thread_id"` is used to track this particular conversation thread.

- **Creating the Input Message:**  
  ```python
  input_message = HumanMessage(content="Can you play Taylor Swift's most popular song?")
  ```  
  We create an instance of `HumanMessage` containing our query. This object is what we send to the agent.

- **Streaming the Agent’s Response:**  
  ```python
  for event in app.stream({"messages": [input_message]}, config, stream_mode="values"):
      event["messages"][-1].pretty_print()
  ```  
  - **`app.stream(...)`:** This method sends our message to the agent and starts streaming the response.  
  - **`{"messages": [input_message]}`:** We pass our input message in a list (allowing multiple messages if needed).  
  - **`config`:** Our previously defined configuration is used to keep track of this conversation.  
  - **`stream_mode="values"`:** This parameter specifies the mode of streaming (here, we’re streaming the values).  
  - **`for event in ...`:** We iterate over the stream of events from the agent.  
  - **`event["messages"][-1].pretty_print()`:** For each event, we access the last message in the list and print it in a nicely formatted way.

---

### 2. Reviewing the Agent’s Interaction History

After interacting with the agent, you might want to see the full conversation history for debugging or analysis.

#### **Accessing the Current State**

```python
# Get the current state and print the conversation messages.
print(app.get_state(config).values["messages"])
```

**Explanation:**

- **`app.get_state(config)`:**  
  This function fetches the current state of the conversation using the configuration we provided.
  
- **`.values["messages"]`:**  
  We access the `messages` list from the state. This list contains all the messages exchanged so far (both user and agent responses).

#### **Browsing the Full History**

```python
all_states = []
for state in app.get_state_history(config):
    print(state)
    all_states.append(state)
    print("--")
```

**Explanation:**

- **`app.get_state_history(config)`:**  
  This function returns an iterator over all the historical states (or snapshots) of the conversation.  
- **Looping Through States:**  
  For each state, we print its content and append it to a list (`all_states`) for further analysis.  
- **`print("--")`:**  
  This line is simply to separate each state visually in the output.

---

## 🌍 Real-World Use Case

**Example: AI Music Assistant**  
Imagine you are building an AI-powered music assistant that takes voice or text commands to play songs on various streaming platforms. In such a system:

- **User Interaction:**  
  A user can ask, "Can you play Taylor Swift's most popular song?"  
- **Agent Processing:**  
  The agent processes this request, checks the song popularity, decides which streaming service to use (e.g., Apple Music), and makes an API call to play the song.
- **Debugging and History:**  
  If something goes wrong (e.g., the wrong song plays), you can review the entire conversation history to pinpoint where the error occurred, making it easier to debug and improve the assistant.

---

## 🔑 Key Takeaways

- **Interactive Messaging:**  
  Use the `HumanMessage` class to construct user inputs and stream responses from the agent.
- **Real-Time Streaming:**  
  The `app.stream(...)` method allows you to process and display responses as soon as they are available.
- **State History:**  
  Functions like `app.get_state(config)` and `app.get_state_history(config)` help you monitor the entire conversation flow for debugging and analysis.
- **Practical Application:**  
  These techniques are vital in real-world AI assistants, chatbots, and interactive systems where understanding the state and debugging interactions are crucial.

---
# 🎯 **Replaying and Branching State in LangGraph: A Deep Dive**  

When working with **LangGraph**, an important feature is the ability to **replay and branch off past states**. This enables debugging, workflow modifications, and alternate decision paths in AI-based applications.

---

## 🏆 **1. What is Replaying a State?**  

In LangGraph, every interaction (such as calling an external tool or generating AI responses) is stored as a **state**. If you ever need to **restart from a previous state**, you can do so using replaying.  

### 🔍 **Why is this useful?**
- 🛠️ **Debugging:** If something went wrong, you can retrace steps to find the issue.
- 🔁 **Consistency:** You can ensure your AI model follows the same logic when necessary.
- 🚀 **Workflow Control:** Restart from a critical point instead of running everything from scratch.

### ✅ **Example: Replaying a State**
Suppose a user asks an AI to play a song, but we want to **replay** a previous state before the AI executed a tool call.

```python
# Replaying a previous state in LangGraph

to_replay = all_states[2]  # Selecting the third saved state

to_replay.values  # Displaying the stored values in this state
```
🔹 This fetches and prints the messages stored in that particular **saved state**.

---

## 🎭 **2. How to Resume from a Past State?**  

Once you have the state (`to_replay`), you can **resume execution from that exact moment** using the agent.

```python
# Resuming execution from a replayed state
for event in app.stream(None, to_replay.config):
    for v in event.values():
        print(v)
```

### 🔍 **Real-World Use Case:**
Imagine you're building a **customer support chatbot** that handles refund requests.  
- If a customer gets disconnected, you can **replay their last conversation** instead of restarting from the beginning.  
- This ensures **seamless user experience** by picking up from the last meaningful interaction.

---

## 🔄 **3. What is Branching a State?**  

Branching is **like creating a version control checkpoint**. Instead of replaying the same execution, we can **modify the decision path and create an alternate outcome.**  

### ✅ **Example: Changing the Tool Call**
Let's say our AI originally **played a song on Apple Music**, but we want to change that to **Spotify**.

```python
# Get the last message that contains tool calls
last_message = to_replay.values["messages"][-1]

# Modify the tool call name to play the song on Spotify instead of Apple Music
last_message.tool_calls[0]["name"] = "play_song_on_spotify"

# Update the configuration with the new tool call
branch_config = app.update_state(
    to_replay.config,
    {"messages": [last_message]},
)

# Execute the new branch
for event in app.stream(None, branch_config):
    for v in event.values():
        print(v)
```

### 🔍 **Real-World Use Case:**
- In a **task automation system**, if a workflow originally **sent an email**, but now you want it to **send a Slack message instead**, you can **branch the state** and rerun it with the modified logic.

---

## 🚫 **4. What if We Want to Skip a Tool Call?**  

Instead of calling a tool (playing music), we might want to **cancel the action** entirely.

```python
from langchain_core.messages import AIMessage

# Get the last message in the state
last_message = to_replay.values["messages"][-1]

# Create a new message instead of calling the tool
new_message = AIMessage(
    content="It's quiet hours so I can't play any music right now!", 
    id=last_message.id
)

# Update the branch state
branch_config = app.update_state(
    to_replay.config,
    {"messages": [new_message]},
)

# Get the updated state
branch_state = app.get_state(branch_config)

# View the new state
branch_state.values
```
### 🔍 **Real-World Use Case:**
- If your **automated system detects it’s past business hours**, it can **skip calling external services** and instead **send a custom message** like:
  > "Customer support is unavailable at the moment. Please try again later."

---

## 🔥 **Conclusion: Mastering Replay & Branching**  

| Feature        | Purpose |
|---------------|---------|
| 🔄 **Replay**  | Resumes execution from a past state for debugging & consistency. |
| 🌿 **Branching**  | Creates a new workflow by modifying decisions. |
| ❌ **Skipping Tool Calls** | Avoids executing certain steps based on new conditions. |

These techniques provide powerful **debugging, automation, and workflow management** for **AI applications, customer support bots, and automated decision-making systems**. 🚀

# 🔄 Replay & Branch Off a Past State in LangGraph

LangGraph’s checkpointing lets you **replay** a past state of your workflow or even **branch off** from it. This powerful feature is useful for debugging, testing alternate paths, or giving users more control over the execution of a workflow.

In this guide, we'll cover:

- **Replay a State:** Restart the agent from a previous checkpoint.
- **Branch Off a State:** Modify a past state to change the flow or outcome.

Let's dive into the code examples and break down each step!

---

## ▶️ Replay a Past State

### **What Does It Mean?**

Imagine your AI assistant is in the middle of a conversation and about to execute a tool call. With replay, you can rewind the workflow to that exact moment and resume execution from there. This is great for debugging or reproducing specific scenarios.

### **Code Example & Explanation**

```python
# Choose the state we want to replay
to_replay = all_states[2]
```

- **Purpose:**  
  We select a specific checkpoint from the `all_states` list (the third state, as indexing starts at 0) where we want to replay the workflow.

---

```python
# Inspect the values of the selected state
to_replay.values
```

- **Purpose:**  
  This shows the stored values at that checkpoint, which includes:
  - A `HumanMessage` asking, "Can you play Taylor Swift's most popular song?"
  - An `AIMessage` that contains a tool call (e.g., calling `play_song_on_apple`).

---

```python
# Check what node comes next in the workflow
to_replay.next
```

- **Purpose:**  
  This tells us which node is queued to execute next. In our example, it shows `('action',)`—meaning the next action is to execute the tool call.

---

```python
# Replay from this state using its configuration
for event in app.stream(None, to_replay.config):
    for v in event.values():
        print(v)
```

- **Purpose:**  
  - `app.stream(None, to_replay.config)` resumes execution using the saved configuration from the checkpoint.
  - As the workflow resumes, it will complete the tool call.  
  - The loop prints each event’s values, showing that the tool (e.g., playing the song) is executed and a corresponding response is returned.

### **Real-World Example:**

Consider a **troubleshooting assistant** for a smart home system. If a device doesn't respond correctly, the assistant can replay a past state to reattempt a command or test alternate device configurations without starting from scratch.

---

## 🔀 Branch Off a Past State

### **What Does It Mean?**

Branching off a past state lets you modify the workflow at a certain point and explore a different execution path. For example, you might change which tool is called or update a message to reflect a new decision.

### **Scenario:**  
Instead of playing a song on Apple Music, let's modify the state to play it on Spotify.

### **Code Example & Explanation**

```python
# Retrieve the last message from the replayed state, which contains tool calls
last_message = to_replay.values["messages"][-1]
```

- **Purpose:**  
  We get the last message from the state snapshot. This message holds the tool call details that we want to modify.

---

```python
# Update the tool call from Apple Music to Spotify
last_message.tool_calls[0]["name"] = "play_song_on_spotify"
```

- **Purpose:**  
  This line changes the tool call in the message.  
  - Originally, the tool call was for `play_song_on_apple`.  
  - We update it to `play_song_on_spotify` so that the assistant will now call the Spotify tool.

---

```python
# Create a new branch by updating the state with our modified message
branch_config = app.update_state(
    to_replay.config,
    {"messages": [last_message]},
)
```

- **Purpose:**  
  - `app.update_state(...)` takes the old configuration (`to_replay.config`) and applies our changes (the updated `last_message`).  
  - This generates a new configuration (`branch_config`) that reflects our new branch of the workflow.

---

```python
# Resume execution from the branched state
for event in app.stream(None, branch_config):
    for v in event.values():
        print(v)
```

- **Purpose:**  
  - Resumes the workflow using the branched configuration.
  - As the execution continues, you'll see that the tool now called is `play_song_on_spotify` instead of `play_song_on_apple`.
  - The output shows that the song is played on Spotify.

---

### **Alternative Branching: Changing the Outcome**

Sometimes you may want to completely override a tool call. For example, if it’s "quiet hours" and you don't want any music to play, you can update the state with a new message.

```python
from langchain_core.messages import AIMessage

# Get the last message with the tool call
last_message = to_replay.values["messages"][-1]

# Create a new AI message with the same ID, indicating a different decision
new_message = AIMessage(
    content="It's quiet hours so I can't play any music right now!",
    id=last_message.id
)
```

- **Purpose:**  
  - We create a new `AIMessage` to replace the original message.
  - Notice that we reuse the same `id` to maintain consistency in the workflow's state.

---

```python
# Update the state with the new AI message
branch_config = app.update_state(
    to_replay.config,
    {"messages": [new_message]},
)
```

- **Purpose:**  
  This updates the workflow state with our new message, effectively canceling the tool call.

---

```python
# Fetch the updated state to verify changes
branch_state = app.get_state(branch_config)
print(branch_state.values)
```

- **Purpose:**  
  - Retrieves and prints the updated state.
  - The output confirms that the tool call has been replaced by our new message:  
    > "It's quiet hours so I can't play any music right now!"

---

### **Real-World Example:**

Imagine a **customer support chatbot**. A user might request an action that could be dangerous or inappropriate under certain circumstances. By branching off the state, the system can insert a new decision (like "Sorry, this action is currently disabled") without redoing the entire conversation.

---

## 🔑 Key Takeaways

- **Replay a State:**  
  You can rewind to any saved checkpoint and resume execution from that exact point. This is invaluable for debugging and reproducing specific scenarios.

- **Branch Off a State:**  
  By modifying a past state, you can explore alternate execution paths. Whether you want to change which tool is called or override an action completely, branching off gives you flexibility.

- **Real-World Utility:**  
  These techniques are crucial in dynamic systems like smart home assistants, customer support bots, or any interactive AI that requires fine control over its execution flow.

With these concepts, you’re equipped to control and debug your LangGraph workflows in a robust and flexible way. Happy coding!

