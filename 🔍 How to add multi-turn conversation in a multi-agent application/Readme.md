Below is a detailed, beginner-friendly explanation of how to add multi-turn conversation in a multi-agent application. We'll break down the core concepts, explain each code snippet line by line, and even show a real-world example scenario.

---

# 🚀 Overview of Multi-Turn Conversations in Multi-Agent Systems

Multi-turn conversations allow users to interact with an application over several back-and-forth exchanges. In a **multi-agent system**, different “agents” (or specialized bots) handle different tasks. For example, one agent might recommend travel destinations while another suggests hotels. The conversation can smoothly transition (or “handoff”) between these agents based on user input or internal logic.

---

# 🛠️ Key Concepts

- **Interrupts:** These pause the automated flow to wait for user input.
- **Commands:** Objects that update the conversation state and determine which agent (or node) should process the next step.
- **Nodes:** Parts of the application (often represented as functions) that represent different conversation roles—like a human node or an agent node.
- **Handoff:** The process of transferring control from one agent to another, ensuring a seamless conversation.

---

# 🔍 Understanding the Code

Let's break down the example code provided into two main parts: the **human node** for collecting user input and the **agent node** for processing the conversation.

---

## 1. The Human Node: Collecting User Input

This node is responsible for gathering input from the user and then routing the conversation to the appropriate agent.

```python
def human(state: MessagesState) -> Command[Literal["agent", "another_agent"]]:
    """A node for collecting user input."""
    user_input = interrupt(value="Ready for user input.")
    
    # Determine the active agent.
    active_agent = ...
    
    return Command(
        update={
            "messages": [{
                "role": "human",
                "content": user_input,
            }]
        },
        goto=active_agent
    )
```

### Explanation Line by Line

- **Function Definition:**
  ```python
  def human(state: MessagesState) -> Command[Literal["agent", "another_agent"]]:
  ```
  - **What it does:**  
    This function is called `human` and takes the current conversation state (`state`) as input. It returns a `Command` that tells the system what to do next.
  - **Purpose:**  
    To act as the entry point for user input in a multi-turn conversation.

- **Interrupting for Input:**
  ```python
  user_input = interrupt(value="Ready for user input.")
  ```
  - **What it does:**  
    The `interrupt` function pauses the flow to get input from the user. The message `"Ready for user input."` is shown to the user.
  - **Purpose:**  
    To collect the next message or instruction from the user, effectively allowing a multi-turn conversation.

- **Determining the Active Agent:**
  ```python
  active_agent = ...
  ```
  - **What it does:**  
    Here, the code should determine which agent (e.g., `"agent"` or `"another_agent"`) should handle the next step.
  - **Purpose:**  
    To decide whether to continue with the same agent or transfer (handoff) to a different one.

- **Returning the Command:**
  ```python
  return Command(
      update={
          "messages": [{
              "role": "human",
              "content": user_input,
          }]
      },
      goto=active_agent
  )
  ```
  - **What it does:**  
    This creates and returns a `Command` that updates the conversation state by appending the user's message. The `goto` field specifies which agent should process the next step.
  - **Purpose:**  
    To seamlessly hand off the conversation to the determined agent while keeping a record of the conversation.

---

## 2. The Agent Node: Processing and Routing

This node processes the conversation based on internal logic and determines whether to continue with the conversation or hand off to another agent.

```python
def agent(state) -> Command[Literal["agent", "another_agent", "human"]]:
    # The condition for routing/halting can be anything, e.g. LLM tool call / structured output, etc.
    goto = get_next_agent(...)  # 'agent' / 'another_agent'
    if goto:
        return Command(goto=goto, update={"my_state_key": "my_state_value"})
    else:
        return Command(goto="human") # Go to human node
```

### Explanation Line by Line

- **Function Definition:**
  ```python
  def agent(state) -> Command[Literal["agent", "another_agent", "human"]]:
  ```
  - **What it does:**  
    The function named `agent` takes the current state and returns a `Command` that might instruct the system to continue with an agent, switch to another agent, or return control to the human node.
  - **Purpose:**  
    To act as a decision-maker within the conversation flow.

- **Determine the Next Agent:**
  ```python
  goto = get_next_agent(...)
  ```
  - **What it does:**  
    This line uses some internal logic (which might include calling a language model or evaluating conditions) to decide the next agent.
  - **Purpose:**  
    To dynamically choose the next step in the conversation.

- **Conditional Routing:**
  ```python
  if goto:
      return Command(goto=goto, update={"my_state_key": "my_state_value"})
  else:
      return Command(goto="human") # Go to human node
  ```
  - **What it does:**  
    - If `goto` is determined (meaning an agent is chosen), a `Command` is returned that routes the conversation to that agent and updates the state.
    - If no agent is selected, the conversation returns to the human node for more input.
  - **Purpose:**  
    To ensure the conversation flow is correctly routed based on the agent’s logic.

---

# 🌐 Real-World Example: Travel Assistant Chatbot

Imagine you’re building a chatbot for a travel company. This chatbot has two specialized agents:

- **Travel Advisor:**  
  Recommends travel destinations.
- **Hotel Advisor:**  
  Suggests hotel options based on the selected destination.

### How It Works

1. **User Interaction:**  
   The conversation starts with the human node, asking the user for input like “I want to travel.”

2. **Initial Routing:**  
   The conversation is then routed to the **Travel Advisor** agent, which may ask, “Would you like recommendations for destinations?” 

3. **Handoff for Specific Needs:**  
   If the user picks a destination, the **Travel Advisor** might decide to transfer the conversation to the **Hotel Advisor** by using a handoff tool. The **Hotel Advisor** then provides hotel recommendations.

4. **Multi-Turn Conversation:**  
   The conversation can go back and forth: if the hotel agent needs more information, it can ask the user for input (returning to the human node) or even switch back to the travel agent for further advice.

---

# 💻 Defining Agents and Tools

Below is the code for defining tools used by these agents. These tools simulate actions like fetching travel or hotel recommendations and handling handoffs.

```python
import random
from typing import Annotated, Literal

from langchain_core.tools import tool
from langchain_core.tools.base import InjectedToolCallId
from langgraph.prebuilt import InjectedState

# 🔑 Tool to get travel destination recommendations.
@tool
def get_travel_recommendations():
    """Get recommendation for travel destinations"""
    return random.choice(["aruba", "turks and caicos"])

# 🔑 Tool to get hotel recommendations based on a destination.
@tool
def get_hotel_recommendations(location: Literal["aruba", "turks and caicos"]):
    """Get hotel recommendations for a given destination."""
    return {
        "aruba": [
            "The Ritz-Carlton, Aruba (Palm Beach)",
            "Bucuti & Tara Beach Resort (Eagle Beach)"
        ],
        "turks and caicos": ["Grace Bay Club", "COMO Parrot Cay"],
    }[location]

# 🔑 Function to create a handoff tool for transferring control to another agent.
def make_handoff_tool(*, agent_name: str):
    """Create a tool that can return handoff via a Command"""
    tool_name = f"transfer_to_{agent_name}"

    @tool(tool_name)
    def handoff_to_agent(
        state: Annotated[dict, InjectedState],
        tool_call_id: Annotated[str, InjectedToolCallId],
    ):
        """Ask another agent for help."""
        tool_message = {
            "role": "tool",
            "content": f"Successfully transferred to {agent_name}",
            "name": tool_name,
            "tool_call_id": tool_call_id,
        }
        return Command(
            # Navigate to another agent node in the PARENT graph.
            goto=agent_name,
            graph=Command.PARENT,
            # Update the agent's state with the full message history plus our handoff message.
            update={"messages": state["messages"] + [tool_message]},
        )

    return handoff_to_agent
```

### Explanation of the Tools Code

- **Import Statements:**  
  These import necessary modules and types, ensuring our tools work with the multi-agent framework.
  
- **`get_travel_recommendations`:**  
  - Uses Python’s `random.choice` to simulate selecting a travel destination.
  - **Real-world use:** Could query a database or API for actual travel destinations.
  
- **`get_hotel_recommendations`:**  
  - Accepts a `location` (either `"aruba"` or `"turks and caicos"`) and returns a list of hotel names.
  - **Real-world use:** This could be linked to a hotel booking API to fetch current hotel deals.

- **`make_handoff_tool`:**  
  - Dynamically creates a tool that lets one agent hand off control to another.
  - **Inside `handoff_to_agent`:**  
    - A `tool_message` is prepared to log that a handoff occurred.
    - A `Command` is returned with:
      - `goto=agent_name`: Tells the system which agent to switch to.
      - `graph=Command.PARENT`: Indicates that this handoff affects the parent conversation graph.
      - `update={"messages": ...}`: Passes the full conversation history (updated with the handoff message) to the next agent.
  - **Real-world use:** In a customer service chatbot, this tool could be used to transfer a conversation from a general inquiry bot to a specialized billing or technical support agent.

---

# 📝 Summary

- **Multi-turn conversations** allow for back-and-forth interactions with multiple agents.
- **Interrupts and Commands** are used to pause for user input and to manage the conversation flow.
- **Nodes** (like the `human` and `agent` functions) determine which part of the conversation should run next.
- **Tools** such as `get_travel_recommendations`, `get_hotel_recommendations`, and the handoff tool help in executing specific tasks and transferring conversation control.

This design makes your application flexible and powerful—perfect for real-world systems like travel booking chatbots or any service requiring coordinated multi-agent interaction.

Feel free to ask if you have any questions or need further clarification!

---

Below is a detailed, beginner-friendly explanation of the code that creates multi-turn agents using the prebuilt `create_react_agent` along with a dedicated human node. We'll explain every section and line of code, use icons for visual appeal, and even show a real-world use case example.

---

# 🚀 Overview

This code builds a multi-agent system for a travel assistant application. In this system:  
- **Travel Advisor Agent:** Recommends travel destinations.  
- **Hotel Advisor Agent:** Provides hotel recommendations based on a destination.  
- **Human Node:** Waits for user input and routes the conversation back to the active agent.

The agents are created using a prebuilt function (`create_react_agent`) that sets up a ReAct (Reasoning + Acting) agent. Each agent node is wrapped in a function that returns a `Command` to route to the human node after processing.

---

# 🔧 Code Breakdown

Below, we walk through the code step by step.

---

## 1. Importing Required Modules

```python
from langchain_anthropic import ChatAnthropic
from langgraph.graph import MessagesState, StateGraph, START
from langgraph.prebuilt import create_react_agent, InjectedState
from langgraph.types import Command, interrupt
from langgraph.checkpoint.memory import MemorySaver
```

### Explanation:
- **`ChatAnthropic`**: A model class for interacting with Anthropic's language model (here, `"claude-3-5-sonnet-latest"`).
- **`MessagesState` and `StateGraph`**: Types to manage conversation state and to build the conversation graph.
- **`START`**: A constant representing the starting point of the graph.
- **`create_react_agent`**: A helper function to quickly create a ReAct agent.
- **`InjectedState`**: Used for dependency injection into our agent tools.
- **`Command` and `interrupt`**: `Command` objects dictate how the conversation state is updated and where to go next; `interrupt` is used to pause for user input.
- **`MemorySaver`**: A simple checkpointer that saves conversation history in memory.

---

## 2. Setting Up the Model

```python
model = ChatAnthropic(model="claude-3-5-sonnet-latest")
```

### Explanation:
- We instantiate our language model using Anthropic's API.  
- **Purpose:** This model will power our agents’ responses.

---

## 3. Creating the Travel Advisor Agent

### 3.1 Define Tools for the Travel Advisor

```python
# Define travel advisor tools and ReAct agent
travel_advisor_tools = [
    get_travel_recommendations,
    make_handoff_tool(agent_name="hotel_advisor"),
]
```

### Explanation:
- **`get_travel_recommendations`**: A tool (previously defined elsewhere) that returns a travel destination.
- **`make_handoff_tool(agent_name="hotel_advisor")`**: A tool that allows the travel advisor to transfer control to the hotel advisor when needed.
- **Purpose:** These tools enable the travel advisor to both provide recommendations and hand off tasks.

### 3.2 Create the Agent

```python
travel_advisor = create_react_agent(
    model,
    travel_advisor_tools,
    prompt=(
        "You are a general travel expert that can recommend travel destinations (e.g. countries, cities, etc). "
        "If you need hotel recommendations, ask 'hotel_advisor' for help. "
        "You MUST include human-readable response before transferring to another agent."
    ),
)
```

### Explanation:
- **`create_react_agent`**: Initializes an agent using the provided model, tools, and prompt.  
- **Prompt:** Tells the agent its role, what to do, and that it should provide a human-readable answer before transferring the conversation if needed.
- **Purpose:** To set up a dedicated travel advisor agent that knows when and how to transfer control to the hotel advisor.

### 3.3 Define the Node Function for the Travel Advisor

```python
def call_travel_advisor(
    state: MessagesState,
) -> Command[Literal["hotel_advisor", "human"]]:
    # You can also add additional logic like changing the input to the agent / output from the agent, etc.
    # NOTE: we're invoking the ReAct agent with the full history of messages in the state
    response = travel_advisor.invoke(state)
    return Command(update=response, goto="human")
```

### Explanation:
- **`call_travel_advisor(state)`**: A function that acts as a node in the conversation graph.
- **`travel_advisor.invoke(state)`**: Passes the current conversation state (all past messages) to the travel advisor agent to generate a response.
- **`Command(update=response, goto="human")`**:  
  - **`update=response`**: Updates the conversation state with the agent's response.  
  - **`goto="human"`**: Routes the conversation to the human node after the response is provided.
- **Purpose:** To process the travel advisor’s response and then hand off control back to the human for further input.

---

## 4. Creating the Hotel Advisor Agent

### 4.1 Define Tools for the Hotel Advisor

```python
# Define hotel advisor tools and ReAct agent
hotel_advisor_tools = [
    get_hotel_recommendations,
    make_handoff_tool(agent_name="travel_advisor"),
]
```

### Explanation:
- **`get_hotel_recommendations`**: Returns hotel recommendations for a given destination.
- **`make_handoff_tool(agent_name="travel_advisor")`**: Allows the hotel advisor to hand control back to the travel advisor if necessary.
- **Purpose:** To equip the hotel advisor with the ability to recommend hotels and switch back if required.

### 4.2 Create the Agent

```python
hotel_advisor = create_react_agent(
    model,
    hotel_advisor_tools,
    prompt=(
        "You are a hotel expert that can provide hotel recommendations for a given destination. "
        "If you need help picking travel destinations, ask 'travel_advisor' for help."
        "You MUST include human-readable response before transferring to another agent."
    ),
)
```

### Explanation:
- Similar to the travel advisor, we initialize the hotel advisor agent with its own prompt and tools.
- **Prompt:** Instructs the agent about its role and how to perform handoffs if additional information is needed.
- **Purpose:** To define the behavior of the hotel advisor agent.

### 4.3 Define the Node Function for the Hotel Advisor

```python
def call_hotel_advisor(
    state: MessagesState,
) -> Command[Literal["travel_advisor", "human"]]:
    response = hotel_advisor.invoke(state)
    return Command(update=response, goto="human")
```

### Explanation:
- **`call_hotel_advisor(state)`**: Functions as the node for the hotel advisor.
- **`hotel_advisor.invoke(state)`**: Invokes the hotel advisor agent using the current conversation state.
- **`Command(update=response, goto="human")`**: Updates the state with the agent’s response and routes back to the human node.
- **Purpose:** To process and update the conversation with hotel advisor responses.

---

## 5. Creating the Human Node

```python
def human_node(
    state: MessagesState, config
) -> Command[Literal["hotel_advisor", "travel_advisor", "human"]]:
    """A node for collecting user input."""
    user_input = interrupt(value="Ready for user input.")
    
    # Identify the last active agent (the last active node before returning to human)
    langgraph_triggers = config["metadata"]["langgraph_triggers"]
    if len(langgraph_triggers) != 1:
        raise AssertionError("Expected exactly 1 trigger in human node")
    
    active_agent = langgraph_triggers[0].split(":")[1]
    
    return Command(
        update={
            "messages": [
                {
                    "role": "human",
                    "content": user_input,
                }
            ]
        },
        goto=active_agent,
    )
```

### Explanation:
- **`human_node(state, config)`**: Collects user input when the system reaches this node.
- **`interrupt(value="Ready for user input.")`**: Pauses the conversation and displays a prompt for the user.
- **`config["metadata"]["langgraph_triggers"]`**: Extracts metadata to determine which agent was active before reaching the human node.
- **`if len(langgraph_triggers) != 1: ...`**: Ensures that exactly one agent trigger is present.
- **`active_agent = langgraph_triggers[0].split(":")[1]`**: Parses the trigger to get the name of the active agent.
- **`Command(update=..., goto=active_agent)`**: Updates the conversation with the new human message and routes back to the previously active agent.
- **Purpose:** To seamlessly collect user input and re-route the conversation to the correct agent.

---

## 6. Building the Conversation Graph

```python
builder = StateGraph(MessagesState)
builder.add_node("travel_advisor", call_travel_advisor)
builder.add_node("hotel_advisor", call_hotel_advisor)
builder.add_node("human", human_node)

# We'll always start with a general travel advisor.
builder.add_edge(START, "travel_advisor")

checkpointer = MemorySaver()
graph = builder.compile(checkpointer=checkpointer)
```

### Explanation:
- **`StateGraph(MessagesState)`**: Initializes a new conversation graph using our `MessagesState` type.
- **`builder.add_node("travel_advisor", call_travel_advisor)`**: Adds the travel advisor node to the graph.
- **`builder.add_node("hotel_advisor", call_hotel_advisor)`**: Adds the hotel advisor node.
- **`builder.add_node("human", human_node)`**: Adds the human node for user input.
- **`builder.add_edge(START, "travel_advisor")`**: Sets the starting point of the conversation to the travel advisor.
- **`MemorySaver()`**: Creates a checkpointer that saves the conversation history in memory.
- **`builder.compile(checkpointer=checkpointer)`**: Compiles the conversation graph into a runnable object.
- **Purpose:**  
  - To define the flow of conversation between agents and the human.
  - To compile and checkpoint the conversation, ensuring state persistence.

---

# 🌍 Real-World Example

Imagine you’re building a **travel booking chatbot** for a travel agency website:
- **User begins:** "I want to travel somewhere warm."
- **Travel Advisor:** The chatbot recommends destinations like Aruba or Turks and Caicos.
- **User selects a destination:**  
  The travel advisor then hands off to the hotel advisor to suggest hotels.
- **Hotel Advisor:** Provides a list of hotels in the chosen destination.
- **User feedback:** The conversation loops back to the human node where the user can type further queries (e.g., "What are the hotel prices?").
- **Flow Continuity:** The system ensures the correct agent (travel or hotel advisor) handles the query based on the last active state.

This setup allows a complex, multi-turn conversation where specialized agents handle different aspects of the conversation, all while maintaining a smooth user experience.

---

# 📝 Summary

- **Agents and Nodes:**  
  - **Travel Advisor and Hotel Advisor** are created using `create_react_agent` with their own prompts and tool sets.
  - Each agent node function (`call_travel_advisor` and `call_hotel_advisor`) processes conversation history and then routes back to the human node.
- **Human Node:**  
  - Waits for user input and determines which agent should receive the next message based on metadata.
- **StateGraph:**  
  - Builds and compiles a conversation graph, linking nodes and ensuring proper state management.
- **Real-World Use Case:**  
  - Perfect for a travel booking chatbot that needs to seamlessly transition between recommending destinations and suggesting hotels.

This design demonstrates how to build a multi-turn, multi-agent conversational system where human input is integrated with dynamic agent responses. Feel free to ask if you have any questions or need further clarification!

---

Below is a detailed, beginner-friendly explanation of the test multi-turn conversation code. We’ll break down each line, explain what’s happening, and discuss a real-world scenario where this might be used.

---

# 🚀 Overview of Testing Multi-Turn Conversations

In this example, we simulate a multi-turn conversation using our multi-agent travel assistant application. The conversation is split into rounds where:
- **Round 1:** The user initiates the conversation.
- **Round 2:** The system (agent) receives a command to resume the conversation (using an interrupt).
- **Round 3:** The conversation continues based on the user's follow-up.

This setup allows us to test how the conversation flows between agents and human input over several turns.

---

# 🛠️ Detailed Code Explanation

Below is the code along with a detailed explanation of each section.

```python
import uuid

# Create a unique thread configuration for the conversation.
thread_config = {"configurable": {"thread_id": uuid.uuid4()}}
```

- **`import uuid`**  
  - **Purpose:** The `uuid` module is used to generate a unique identifier.
  - **Usage:** A unique thread ID is created to uniquely identify this conversation session.

- **`thread_config = {"configurable": {"thread_id": uuid.uuid4()}}`**  
  - **Purpose:** Creates a configuration dictionary that includes a unique `thread_id`.  
  - **Real-World Analogy:** Imagine each conversation on a customer support chat gets its own ticket number so that all messages related to that conversation are tracked together.

---

```python
inputs = [
    # 1st round of conversation,
    {
        "messages": [
            {"role": "user", "content": "i wanna go somewhere warm in the caribbean"}
        ]
    },
    # 2nd round: Using `interrupt`, we resume the conversation with a new Command.
    Command(
        resume="could you recommend a nice hotel in one of the areas and tell me which area it is."
    ),
    # 3rd round: Another command to continue the conversation.
    Command(
        resume="i like the first one. could you recommend something to do near the hotel?"
    ),
]
```

- **`inputs = [...]`**  
  - **Purpose:** A list of conversation turns is defined.
  - **Breakdown:**
    - **First Input:** A dictionary with a key `"messages"` containing the user’s initial message.
    - **Second & Third Inputs:** `Command` objects with a `resume` message. These simulate the user providing additional input after the system has interrupted for more details.
  - **Real-World Analogy:** Think of it as a conversation in a messaging app—each message (or command) is sent in sequence.

---

```python
for idx, user_input in enumerate(inputs):
    print()
    print(f"--- Conversation Turn {idx + 1} ---")
    print()
    print(f"User: {user_input}")
    print()
```

- **`for idx, user_input in enumerate(inputs):`**  
  - **Purpose:** Loops through each conversation round (input).
  - **Usage:** `enumerate` gives us both the index (turn number) and the user input.

- **`print(f"--- Conversation Turn {idx + 1} ---")`**  
  - **Purpose:** Prints a header for each conversation turn to visually separate them.
  
- **`print(f"User: {user_input}")`**  
  - **Purpose:** Displays the user input for the current turn.

---

```python
    for update in graph.stream(
        user_input,
        config=thread_config,
        stream_mode="updates",
    ):
        for node_id, value in update.items():
            if isinstance(value, dict) and value.get("messages", []):
                last_message = value["messages"][-1]
                if isinstance(last_message, dict) or last_message.type != "ai":
                    continue
                print(f"{node_id}: {last_message.content}")
```

- **`for update in graph.stream(...):`**  
  - **Purpose:** Streams the conversation updates from our compiled conversation graph.
  - **Parameters:**
    - **`user_input`**: The current round’s input.
    - **`config=thread_config`**: Passes our unique thread configuration.
    - **`stream_mode="updates"`**: Indicates we want to receive incremental updates as the conversation processes.

- **`for node_id, value in update.items():`**  
  - **Purpose:** Iterates over each node (agent or human node) that produced an update.
  
- **`if isinstance(value, dict) and value.get("messages", []):`**  
  - **Purpose:** Checks if the update contains a `"messages"` list.
  
- **`last_message = value["messages"][-1]`**  
  - **Purpose:** Retrieves the last message from the update (this is typically the newest message from an agent).

- **`if isinstance(last_message, dict) or last_message.type != "ai": continue`**  
  - **Purpose:** Ensures we only print messages generated by the AI (ignoring non-AI messages such as those from the human node).
  
- **`print(f"{node_id}: {last_message.content}")`**  
  - **Purpose:** Prints the node ID (e.g., `travel_advisor` or `hotel_advisor`) along with the content of its latest response.

---

# 🌍 Real-World Use Case Example

Imagine you're interacting with a travel chatbot on a travel booking website:

1. **User Initiation:**  
   - *User*: "I wanna go somewhere warm in the Caribbean."  
   - *Travel Advisor*: Responds with a suggestion, e.g., "I recommend Aruba!"

2. **Follow-Up:**  
   - *User*: "Could you recommend a nice hotel in one of the areas and tell me which area it is?"  
   - *Hotel Advisor*: Provides a list of hotels with area details (like Palm Beach or Eagle Beach).

3. **Further Inquiry:**  
   - *User*: "I like the first one. Could you recommend something to do near the hotel?"  
   - *Travel Advisor*: Lists nearby activities such as water sports, shopping, or local attractions.

This example mirrors our multi-turn conversation where the conversation flows back and forth between the travel advisor and hotel advisor based on user commands.

---

# 📝 Summary

- **Unique Thread Configuration:**  
  A unique thread ID is generated to track the conversation session.

- **Input Rounds:**  
  The conversation is defined in multiple rounds using a mix of dictionary inputs and `Command` objects to simulate pauses (interrupts) and resumes.

- **Graph Streaming:**  
  The conversation graph processes each input round, and we stream updates to capture the agents’ responses.

- **Filtering Updates:**  
  We loop through each update to display only the AI-generated responses from the correct node.

This setup is ideal for real-world applications like customer service or travel booking chatbots where conversations may span multiple turns and require smooth transitions between different topics or agents.

Feel free to ask if you have any questions or need more details on any part of the process!

---

# 🗨️ Understanding Multi-Turn Conversations in Python 📝

Multi-turn conversations are a fundamental concept in chatbot development. They allow a chatbot to maintain context across multiple interactions with a user, making the experience feel more natural and interactive.

In this explanation, we'll go deep into:
- What multi-turn conversations are 🤖
- How they work in real-world applications 🌍
- A detailed breakdown of the provided Python code 🖥️
- A step-by-step explanation of each line of the code 📌
- Real-world use cases where this technique is applied ✅

---

## 🔥 What is a Multi-Turn Conversation?
A **multi-turn conversation** refers to an interactive dialogue where the chatbot or AI system can remember past user inputs and respond contextually. Instead of treating every message as a standalone query, it builds upon previous interactions.

💡 **Example in Real Life:**  
Imagine you are booking a hotel through an AI assistant:  
1️⃣ You ask: *"I want to visit a warm place in the Caribbean."*  
2️⃣ The chatbot suggests *Aruba.*  
3️⃣ You ask: *"Can you recommend a hotel there?"*  
4️⃣ The chatbot lists options.  
5️⃣ You say: *"I like the first one. What activities are nearby?"*  
6️⃣ The chatbot provides a list of things to do.  

Each turn builds upon the last, making it a **multi-turn** conversation.

---

## 🏗️ How the Code Works
The provided Python script simulates a chatbot handling a multi-turn conversation. Let's break it down step by step.

### **📌 Step 1: Importing Necessary Modules**
```python
import uuid
```
🔹 `uuid` is a built-in Python module that generates **unique identifiers**. It is used to assign a unique ID to each conversation session.

---

### **📌 Step 2: Defining Conversation Configuration**
```python
thread_config = {"configurable": {"thread_id": uuid.uuid4()}}
```
🔹 `thread_config` is a dictionary that holds configuration settings for the conversation.  
🔹 `uuid.uuid4()` generates a random **thread ID**, ensuring each conversation session is unique.  
🔹 This helps the chatbot remember user interactions in a structured way.

---

### **📌 Step 3: Defining User Inputs**
```python
inputs = [
    # 1st round of conversation,
    {
        "messages": [
            {"role": "user", "content": "i wanna go somewhere warm in the caribbean"}
        ]
    },
    # Since we're using `interrupt`, we'll need to resume using the Command primitive.
    # 2nd round of conversation,
    Command(
        resume="could you recommend a nice hotel in one of the areas and tell me which area it is."
    ),
    # 3rd round of conversation,
    Command(
        resume="i like the first one. could you recommend something to do near the hotel?"
    ),
]
```
🔹 This list `inputs` stores multiple user inputs as **conversation turns**.  
🔹 The first message asks for travel recommendations.  
🔹 The `Command(resume=...)` is used to continue the conversation with follow-up questions.  

**💡 Key Concept:**  
The chatbot **remembers previous messages** and can provide contextual responses.

---

### **📌 Step 4: Processing the Conversation**
```python
for idx, user_input in enumerate(inputs):
    print()
    print(f"--- Conversation Turn {idx + 1} ---")
    print()
    print(f"User: {user_input}")
    print()
```
🔹 This loop **iterates through each conversation turn** in the `inputs` list.  
🔹 `idx + 1` helps track the conversation turn number.  
🔹 `print()` statements format and display each conversation turn.

---

### **📌 Step 5: AI Response Handling**
```python
for update in graph.stream(
    user_input,
    config=thread_config,
    stream_mode="updates",
):
    for node_id, value in update.items():
        if isinstance(value, dict) and value.get("messages", []):
            last_message = value["messages"][-1]
            if isinstance(last_message, dict) or last_message.type != "ai":
                continue
            print(f"{node_id}: {last_message.content}")
```
🔹 `graph.stream()` is used to simulate a chatbot generating responses.  
🔹 It **streams responses** dynamically as they are generated.  
🔹 The chatbot processes each `user_input` and finds the corresponding reply.  
🔹 The code ensures that only **AI-generated responses** (`last_message.type == "ai"`) are printed.  
🔹 The `print()` statement then outputs the chatbot's reply.

---

## 🎯 Real-World Applications
Multi-turn conversations are widely used in:
1️⃣ **Customer Support Bots** (e.g., **ChatGPT, Intercom**) – Chatbots that answer FAQs and troubleshoot issues.  
2️⃣ **Virtual Travel Assistants** (e.g., **Expedia, Google Travel**) – Help users plan vacations step by step.  
3️⃣ **AI-Powered Shopping Assistants** (e.g., **Amazon, eBay**) – Guide customers through purchasing decisions.  
4️⃣ **Healthcare Chatbots** (e.g., **Mayo Clinic AI Chatbot**) – Ask follow-up questions to diagnose symptoms.  

---

## 🚀 Complete Example Code
Here’s a **simplified version** of a chatbot handling a multi-turn conversation:

```python
import uuid

# Generate a unique conversation ID
thread_config = {"configurable": {"thread_id": uuid.uuid4()}}

# Define multi-turn user messages
inputs = [
    {"messages": [{"role": "user", "content": "Recommend me a warm place to visit."}]},
    {"messages": [{"role": "user", "content": "What hotels are available there?"}]},
    {"messages": [{"role": "user", "content": "What activities can I do near that hotel?"}]},
]

# Simulating chatbot responses
responses = [
    "I recommend Aruba! It has warm weather all year.",
    "You can stay at The Ritz-Carlton in Palm Beach or Bucuti & Tara Beach Resort in Eagle Beach.",
    "Near The Ritz-Carlton, you can enjoy shopping, water sports, and nightlife.",
]

# Simulate a conversation loop
for idx, (user_input, bot_response) in enumerate(zip(inputs, responses)):
    print(f"--- Conversation Turn {idx + 1} ---")
    print(f"User: {user_input['messages'][0]['content']}")
    print(f"Chatbot: {bot_response}\n")
```

### **📌 Explanation of the Code**
1️⃣ We use `uuid.uuid4()` to generate a unique ID for the conversation.  
2️⃣ `inputs` stores a list of **user messages** at each step.  
3️⃣ `responses` is a list of **chatbot replies** for each turn.  
4️⃣ The `for` loop **iterates through each turn**, displaying both the user input and chatbot response.  

---

## 🎯 Key Takeaways
✅ Multi-turn conversations allow **contextual** interactions.  
✅ They are useful in **chatbots, AI assistants, and recommendation engines**.  
✅ The Python code simulates a chatbot handling user queries **step by step**.  
✅ `uuid` ensures each conversation session is **unique**.  
✅ Chatbot **remembers past interactions** to provide **relevant** answers.  

---

## 🎉 Conclusion
Multi-turn conversations are essential in AI-based chat systems, making interactions **engaging, intelligent, and user-friendly**. This concept is widely used in travel planning, customer service, and e-commerce chatbots.

Would you like help in **implementing** this concept in your own project? 🚀 Let me know! 😊