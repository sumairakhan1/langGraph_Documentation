# Part 3: Conditional Interrupt¶
In this section, we'll refine our interrupt strategy by categorizing tools as safe (read-only) or sensitive (data-modifying). We'll apply interrupts to the sensitive tools only, allowing the bot to handle simple queries autonomously.

This balances user control and conversational flow, but as we add more tools, our single graph may grow too complex for this "flat" structure. We'll address that in the next section.

Your graph for Part 3 will look something like the following diagram.



# State¶
As always, start by defining the graph state. Our state and LLM calling are identical to part 2.

```python
from typing import Annotated

from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable, RunnableConfig
from typing_extensions import TypedDict

from langgraph.graph.message import AnyMessage, add_messages


class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str


class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)
            # If the LLM happens to return an empty response, we will re-prompt it
            # for an actual response.
            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list)
                and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break
        return {"messages": result}


# Haiku is faster and cheaper, but less accurate
# llm = ChatAnthropic(model="claude-3-haiku-20240307")
llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)
# You can update the LLMs, though you may need to update the prompts
# from langchain_openai import ChatOpenAI

# llm = ChatOpenAI(model="gpt-4-turbo-preview")

assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            " Use the provided tools to search for flights, company policies, and other information to assist the user's queries. "
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            " If a search comes up empty, expand your search before giving up."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)


# "Read"-only tools (such as retrievers) don't need a user confirmation to use
part_3_safe_tools = [
    TavilySearchResults(max_results=1),
    fetch_user_flight_information,
    search_flights,
    lookup_policy,
    search_car_rentals,
    search_hotels,
    search_trip_recommendations,
]

# These tools all change the user's reservations.
# The user has the right to control what decisions are made
part_3_sensitive_tools = [
    update_ticket_to_new_flight,
    cancel_ticket,
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
    book_hotel,
    update_hotel,
    cancel_hotel,
    book_excursion,
    update_excursion,
    cancel_excursion,
]
sensitive_tool_names = {t.name for t in part_3_sensitive_tools}
# Our LLM doesn't have to know which nodes it has to route to. In its 'mind', it's just invoking functions.
part_3_assistant_runnable = assistant_prompt | llm.bind_tools(
    part_3_safe_tools + part_3_sensitive_tools
)

```

# ✨ **Part 3: Conditional Interrupt** ✨

In this section, we will learn how to apply **conditional interrupts** in a chatbot using LangGraph. The **main idea** is to **differentiate between safe (read-only) actions** and **sensitive (data-changing) actions**, allowing the bot to operate autonomously for safe tasks and ask for user confirmation before performing sensitive tasks.

This approach ensures:
- ⚡ **Faster responses** for safe actions  
- 🔒 **User control** over sensitive actions  
- 💬 **Smooth conversation flow**  

---

## 🌟 **What Is a Conditional Interrupt?**  

A **conditional interrupt** allows a chatbot to **pause** when certain actions are about to take place, giving the **user control** to either approve or deny them.  

### 💡 **Real-World Example:**
Imagine a chatbot for a **travel booking website**:
- ✅ **Safe Actions:** Searching for flights, looking up hotel reviews, or checking policies. The bot can do these automatically.  
- 🚫 **Sensitive Actions:** Booking or canceling a flight, reserving a hotel room, or updating tickets. The bot will **ask for your permission** before completing these actions.  

---

## 🔧 **Step-by-Step Explanation with Code**  

### 🏗️ **Step 1: Define the Graph State**  

The **graph state** keeps track of:
- 💬 **Messages exchanged** between the user and the bot  
- 👤 **User information**  

### 💻 **Code Example:**
```python
from typing import Annotated
from langgraph.graph.message import AnyMessage, add_messages
from typing_extensions import TypedDict

class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str
```

### 📝 **Explanation:**
- **`messages:`** A list that stores all the messages between the user and bot.  
- **`user_info:`** Stores information about the user (like name, preferences).  
- **`Annotated` and `add_messages:`** Help track message history for the conversation.  

---

### 🏃 **Step 2: Create the Assistant Class**  

This class handles the chatbot's **response generation**.

### 💻 **Code Example:**
```python
class Assistant:
    def __init__(self, runnable):
        self.runnable = runnable

    def __call__(self, state: State, config):
        while True:
            result = self.runnable.invoke(state)
            # If response is empty, re-prompt the LLM
            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list)
                and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break
        return {"messages": result}
```

### 📝 **Explanation:**
- **`__init__:`** Initializes the Assistant with the AI model (`runnable`).  
- **`__call__:`** When called, it:  
  - 🔄 **Runs the AI model** with the current state.  
  - ⚠️ **Checks for empty responses** and re-prompts if needed.  
  - ✅ **Returns the AI’s response** once it's valid.  

---

### 🧱 **Step 3: Define the Language Model (LLM)**  

We’ll use **Anthropic’s Claude-3 Sonnet** model to power our assistant.  

### 💻 **Code Example:**
```python
from langchain_anthropic import ChatAnthropic
from datetime import datetime
from langchain_core.prompts import ChatPromptTemplate

llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)

assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            " Use the provided tools to search for flights, policies, and assist users."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 📝 **Explanation:**
- **`ChatAnthropic:`** Specifies the AI model.  
- **`temperature:`** Controls response creativity (1 means balanced creativity).  
- **`ChatPromptTemplate:`** Sets instructions for the assistant.  
- **`partial(time=datetime.now):`** Adds the current time to the prompt.  

---

### 🧩 **Step 4: Define Safe and Sensitive Tools**  

- ✅ **Safe Tools:** Can be run without user approval (read-only actions).  
- 🚫 **Sensitive Tools:** Require user confirmation (actions that modify data).  

### 💻 **Code Example:**
```python
# Safe tools - No user confirmation needed
part_3_safe_tools = [
    TavilySearchResults(max_results=1),
    fetch_user_flight_information,
    search_flights,
    lookup_policy,
    search_car_rentals,
    search_hotels,
    search_trip_recommendations,
]

# Sensitive tools - Require user confirmation
part_3_sensitive_tools = [
    update_ticket_to_new_flight,
    cancel_ticket,
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
    book_hotel,
    update_hotel,
    cancel_hotel,
    book_excursion,
    update_excursion,
    cancel_excursion,
]

# Extracting tool names for easy reference
sensitive_tool_names = {t.name for t in part_3_sensitive_tools}
```

### 📝 **Explanation:**
- **Safe Tools:** Only retrieve data. E.g., searching for flights or hotels.  
- **Sensitive Tools:** Change user reservations. E.g., booking or canceling a flight.  
- **`sensitive_tool_names:`** Helps in checking if a tool requires user approval.  

---

### 🎛️ **Step 5: Combine Tools with the Assistant**  

Now, let’s bind the tools to the assistant.  

### 💻 **Code Example:**
```python
part_3_assistant_runnable = assistant_prompt | llm.bind_tools(
    part_3_safe_tools + part_3_sensitive_tools
)
```

### 📝 **Explanation:**
- **`llm.bind_tools:`** Links all tools (safe + sensitive) to the assistant.  
- The assistant will:
  - 🤖 Run safe tools **automatically**.  
  - ⏸️ **Pause** for user approval before running sensitive tools.  

---

## 🌎 **Real-World Use Case: Travel Booking Chatbot**  

### ✈️ **Scenario:**  
A user wants to **book a flight** and **reserve a hotel** via a chatbot.

1. **User:** *"Search for flights from Karachi to Dubai."*  
   - The bot uses a **safe tool** and shows available flights immediately.  

2. **User:** *"Book the 10 AM flight tomorrow."*  
   - The bot **pauses** and asks:  
     > *"Do you confirm booking the 10 AM flight for tomorrow?"*  
   - **User responds "yes"** ✅  
   - The bot proceeds to book the flight.  

3. **User:** *"Cancel my hotel reservation."*  
   - The bot **pauses** again for confirmation because **canceling a hotel** is a **sensitive action**.  

---

## 🔍 **Key Benefits of Conditional Interrupts**  
- ⚡ **Efficiency:** No unnecessary interruptions for simple tasks.  
- 🛡️ **Safety:** Prevents accidental bookings or cancellations.  
- 💬 **Natural Conversation:** Only pauses when absolutely necessary.  

---

## 🎯 **Conclusion**  
We have successfully implemented a **conditional interrupt** mechanism that differentiates between safe and sensitive actions. This approach ensures **efficient handling** of simple queries while giving **users control** over critical decisions.  

By implementing such logic in real-world applications (like travel booking, banking bots, or healthcare assistants), we can create chatbots that are **intelligent, user-friendly, and secure**.  

---

✨ Let me know if you’d like further explanations or additional real-world scenarios! 😊

# Or unzasohail019@gmail.com response:

# 🚀 **Understanding Conditional Interrupts in Chatbots**  

In this section, we'll explore **Conditional Interrupts**, a technique used in chatbot development to differentiate between **safe (read-only)** and **sensitive (data-modifying)** operations.  

This approach ensures:  
✅ **Seamless user experience** – the bot handles simple queries without interruptions.  
⚠️ **User control over critical actions** – sensitive actions require user confirmation.  

We’ll break this down step by step, explaining the code logic and real-world applications.  

---

## 🛠 **What is a Conditional Interrupt?**  

A **Conditional Interrupt** is a strategy where the chatbot:  
1. **Automatically executes safe actions** (like retrieving information).  
2. **Asks for user approval before performing sensitive actions** (like modifying a reservation).  

This prevents unauthorized modifications while allowing the chatbot to function autonomously for non-critical operations.  

### 📌 **Real-World Use Case**  

Imagine you're using an airline chatbot to:  
- 🔎 **Search for flights** – The bot should retrieve flight information without asking for permission.  
- 🛑 **Cancel a booking** – The bot must ask, _"Are you sure you want to cancel?"_ before proceeding.  

This ensures users remain in control of important decisions.  

---

# 🔍 **Step-by-Step Explanation of the Code**  

Let's analyze the **LangChain-based implementation** of Conditional Interrupts.  

### 📌 **1. Defining the State**  

The chatbot needs to store conversation history and user information. We define a **State** class using `TypedDict`:  

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages

class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]  # Stores conversation history
    user_info: str  # Stores details about the user
```

📌 **Explanation:**  
- `messages`: Keeps track of past interactions.  
- `user_info`: Stores user-specific details (e.g., frequent flyer status).  

---

### 📌 **2. Creating the Assistant Class**  

The assistant continuously processes user queries using an **LLM (Language Model) like Claude or GPT**.  

```python
class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable  # Assigns the chatbot logic

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)  # Calls the language model
            
            # Ensures that an empty response is not returned
            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list)
                and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}  # Update the state
            else:
                break
        return {"messages": result}  # Returns the chatbot's response
```

📌 **What’s happening here?**  
- The assistant **invokes the chatbot logic** (`self.runnable.invoke(state)`).  
- If the model returns an **empty response**, it **prompts it again** to ensure useful output.  
- The **conversation state is updated** and returned.  

---

### 📌 **3. Setting Up the Language Model (LLM)**  

We use **Claude 3 Sonnet** as the AI model.  

```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)
```

📌 **Why this model?**  
- `claude-3-sonnet` is a **powerful model** for understanding and generating conversational responses.  
- `temperature=1` allows for **creative responses** while maintaining logical coherence.  

---

### 📌 **4. Defining the Assistant's Behavior**  

We define a **prompt template** to instruct the chatbot on how to assist users.  

```python
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            "Use the provided tools to search for flights, company policies, and other information. "
            "When searching, be persistent. Expand your query if needed."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

📌 **Key Components:**  
✅ **System message** – Guides the chatbot’s behavior.  
✅ **User context (`{user_info}`)** – Ensures responses are personalized.  
✅ **Time parameter (`{time}`)** – Adds real-time context.  

---

### 📌 **5. Categorizing Safe and Sensitive Actions**  

We define two sets of tools:  
1. ✅ **Safe Tools** – No user confirmation needed.  
2. ⚠️ **Sensitive Tools** – Require user approval before execution.  

```python
# Safe tools - Read-only actions
part_3_safe_tools = [
    TavilySearchResults(max_results=1),  # Web search
    fetch_user_flight_information,
    search_flights,
    lookup_policy,
    search_car_rentals,
    search_hotels,
    search_trip_recommendations,
]

# Sensitive tools - Actions that modify user data
part_3_sensitive_tools = [
    update_ticket_to_new_flight,
    cancel_ticket,
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
    book_hotel,
    update_hotel,
    cancel_hotel,
    book_excursion,
    update_excursion,
    cancel_excursion,
]

# Convert sensitive tool names to a set for easy lookup
sensitive_tool_names = {t.name for t in part_3_sensitive_tools}
```

📌 **Explanation:**  
- **Safe tools** allow users to retrieve information **without interruptions**.  
- **Sensitive tools** involve **changing bookings**, requiring **explicit approval**.  
- `sensitive_tool_names` **stores sensitive tool names** in a set for quick reference.  

---

### 📌 **6. Binding the Tools to the Assistant**  

The chatbot combines **both safe and sensitive tools** and invokes the right action dynamically.  

```python
part_3_assistant_runnable = assistant_prompt | llm.bind_tools(
    part_3_safe_tools + part_3_sensitive_tools
)
```

📌 **What’s happening here?**  
- `assistant_prompt` defines the chatbot’s behavior.  
- `llm.bind_tools(...)` **attaches tools** for the chatbot to use.  
- The assistant **automatically selects the appropriate tool** based on user input.  

---

## 🎯 **How Does This Improve Chatbots?**  

✅ **Better User Experience** – The chatbot **autonomously answers questions** while requesting user input for sensitive actions.  

✅ **Increased Security** – Prevents **accidental modifications** by requiring confirmation for important changes.  

✅ **Scalability** – As more tools are added, **managing complex workflows becomes easier**.  

---

## 🚀 **Conclusion**  

In this section, we explored:  
📌 **What Conditional Interrupts are** and why they are useful.  
📌 **How to separate safe vs. sensitive tools** in chatbot development.  
📌 **How to integrate these tools into an AI-powered chatbot**.  

### 🎯 **Key Takeaways:**  
🔹 **Safe actions execute automatically**, while **sensitive actions require approval**.  
🔹 **State management** keeps track of user interactions.  
🔹 **LLMs like Claude/GPT handle chatbot logic and tool invocation**.  

This method provides **a perfect balance between automation and user control**, ensuring a **secure and seamless chatbot experience**. 🚀
---

# Define Graph¶
Now, create the graph. Our graph is almost identical to part 2 except we split out the tools into 2 separate nodes. We only interrupt before the tools that are actually making changes to the user's bookings.

```python
from typing import Literal

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

builder = StateGraph(State)


def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}


# NEW: The fetch_user_info node runs first, meaning our assistant can see the user's flight information without
# having to take an action
builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")
builder.add_node("assistant", Assistant(part_3_assistant_runnable))
builder.add_node("safe_tools", create_tool_node_with_fallback(part_3_safe_tools))
builder.add_node(
    "sensitive_tools", create_tool_node_with_fallback(part_3_sensitive_tools)
)
# Define logic
builder.add_edge("fetch_user_info", "assistant")


def route_tools(state: State):
    next_node = tools_condition(state)
    # If no tools are invoked, return to the user
    if next_node == END:
        return END
    ai_message = state["messages"][-1]
    # This assumes single tool calls. To handle parallel tool calling, you'd want to
    # use an ANY condition
    first_tool_call = ai_message.tool_calls[0]
    if first_tool_call["name"] in sensitive_tool_names:
        return "sensitive_tools"
    return "safe_tools"


builder.add_conditional_edges(
    "assistant", route_tools, ["safe_tools", "sensitive_tools", END]
)
builder.add_edge("safe_tools", "assistant")
builder.add_edge("sensitive_tools", "assistant")

memory = MemorySaver()
part_3_graph = builder.compile(
    checkpointer=memory,
    # NEW: The graph will always halt before executing the "tools" node.
    # The user can approve or reject (or even alter the request) before
    # the assistant continues
    interrupt_before=["sensitive_tools"],
)
API Reference: MemorySaver | StateGraph | tools_condition


from IPython.display import Image, display

try:
    display(Image(part_3_graph.get_graph(xray=True).draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass
```

# Example Conversation¶
Now it's time to try out our newly revised chatbot! Let's run it over the following list of dialog turns. This time, we'll have many fewer confirmations.

```python

import shutil
import uuid

# Update with the backup file so we can restart from the original place in each section
db = update_dates(db)
thread_id = str(uuid.uuid4())

config = {
    "configurable": {
        # The passenger_id is used in our flight tools to
        # fetch the user's flight information
        "passenger_id": "3442 587242",
        # Checkpoints are accessed by thread_id
        "thread_id": thread_id,
    }
}

tutorial_questions = [
    "Hi there, what time is my flight?",
    "Am i allowed to update my flight to something sooner? I want to leave later today.",
    "Update my flight to sometime next week then",
    "The next available option is great",
    "what about lodging and transportation?",
    "Yeah i think i'd like an affordable hotel for my week-long stay (7 days). And I'll want to rent a car.",
    "OK could you place a reservation for your recommended hotel? It sounds nice.",
    "yes go ahead and book anything that's moderate expense and has availability.",
    "Now for a car, what are my options?",
    "Awesome let's just get the cheapest option. Go ahead and book for 7 days",
    "Cool so now what recommendations do you have on excursions?",
    "Are they available while I'm there?",
    "interesting - i like the museums, what options are there? ",
    "OK great pick one and book it for my second day there.",
]


_printed = set()
# We can reuse the tutorial questions from part 1 to see how it does.
for question in tutorial_questions:
    events = part_3_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
    snapshot = part_3_graph.get_state(config)
    while snapshot.next:
        # We have an interrupt! The agent is trying to use a tool, and the user can approve or deny it
        # Note: This code is all outside of your graph. Typically, you would stream the output to a UI.
        # Then, you would have the frontend trigger a new run via an API call when the user has provided input.
        try:
            user_input = input(
                "Do you approve of the above actions? Type 'y' to continue;"
                " otherwise, explain your requested changed.\n\n"
            )
        except:
            user_input = "y"
        if user_input.strip() == "y":
            # Just continue
            result = part_3_graph.invoke(
                None,
                config,
            )
        else:
            # Satisfy the tool invocation by
            # providing instructions on the requested changes / change of mind
            result = part_3_graph.invoke(
                {
                    "messages": [
                        ToolMessage(
                            tool_call_id=event["messages"][-1].tool_calls[0]["id"],
                            content=f"API call denied by user. Reasoning: '{user_input}'. Continue assisting, accounting for the user's input.",
                        )
                    ]
                },
                config,
            )
        snapshot = part_3_graph.get_state(config)

```

```js
================================[1m Human Message [0m=================================

OK could you place a reservation for your recommended hotel? It sounds nice.
==================================[1m Ai Message [0m==================================

[{'text': "Sure, I'd be happy to book the Hilton Basel hotel for your stay since it seems like you're interested in that luxury option.\n\nJust to confirm the details:\n\nHotel: Hilton Basel\nLocation: Basel, Switzerland \nCheck-in: May 2nd, 2024\nCheck-out: May 9th, 2024 \nTotal Nights: 7\n\nThe Hilton Basel is a 5-star luxury hotel located right on the River Rhine. It has an indoor pool, spa, fitness center and multiple dining options on site.", 'type': 'text'}, {'id': 'toolu_01P4J1WqwRTTdY9LTumMCewh', 'input': {'hotel_id': 1}, 'name': 'book_hotel', 'type': 'tool_use'}]
Tool Calls:
  book_hotel (toolu_01P4J1WqwRTTdY9LTumMCewh)
 Call ID: toolu_01P4J1WqwRTTdY9LTumMCewh
  Args:
    hotel_id: 1
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

yes go ahead and book anything that's moderate expense and has availability.
==================================[1m Ai Message [0m==================================

[{'text': "Got it, no problem. For your upcoming trip to Basel, I'll aim for moderately priced but good quality options that are available for your dates. \n\nLet me revise the hotel and rental car bookings:\n\nHotel:", 'type': 'text'}, {'id': 'toolu_01Rj5vmxjSztKxKimH7VYEoc', 'input': {'checkin_date': '2024-05-02', 'checkout_date': '2024-05-09', 'location': 'Basel', 'price_tier': 'Upscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01Rj5vmxjSztKxKimH7VYEoc)
 Call ID: toolu_01Rj5vmxjSztKxKimH7VYEoc
  Args:
    checkin_date: 2024-05-02
    checkout_date: 2024-05-09
    location: Basel
    price_tier: Upscale
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 1}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 1}]
==================================[1m Ai Message [0m==================================

[{'text': 'The Hyatt Regency Basel looks like a good upscale, yet still moderately priced option:', 'type': 'text'}, {'id': 'toolu_01QJHJDcHUczvv1nTzWL57kd', 'input': {'hotel_id': 3}, 'name': 'book_hotel', 'type': 'tool_use'}]
Tool Calls:
  book_hotel (toolu_01QJHJDcHUczvv1nTzWL57kd)
 Call ID: toolu_01QJHJDcHUczvv1nTzWL57kd
  Args:
    hotel_id: 3
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Now for a car, what are my options?
==================================[1m Ai Message [0m==================================

[{'text': 'Sure, let me search for car rental options in Basel for your dates of May 2nd to May 9th:', 'type': 'text'}, {'id': 'toolu_01KRkZuw1z7BxChERpVuGVZB', 'input': {'end_date': '2024-05-09', 'location': 'Basel', 'start_date': '2024-05-02'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_01KRkZuw1z7BxChERpVuGVZB)
 Call ID: toolu_01KRkZuw1z7BxChERpVuGVZB
  Args:
    end_date: 2024-05-09
    location: Basel
    start_date: 2024-05-02
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 1}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
==================================[1m Ai Message [0m==================================

Based on the search results, here are your car rental options in Basel for those dates:

Economy:
- Europcar (previously booked)

Midsize:  
- Thrifty

Premium:
- Enterprise  

Luxury:
- Avis

Since you mentioned looking for moderate options, either the Midsize rental with Thrifty or the Premium rental with Enterprise could be good middle-ground choices in terms of price and vehicle class.

Let me know if you need any other details on vehicle types, pricing information, or if you'd like me to book one of those rental options for your trip.
================================[1m Human Message [0m=================================

Awesome let's just get the cheapest option. Go ahead and book for 7 days
==================================[1m Ai Message [0m==================================

[{'text': "Sure, let's book the cheapest rental car option available for your 7 day stay in Basel from May 2nd to May 9th.", 'type': 'text'}, {'id': 'toolu_01VPFtRDMwb1BWodMSLuXDsr', 'input': {'end_date': '2024-05-09', 'location': 'Basel', 'price_tier': 'Economy', 'start_date': '2024-05-02'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_01VPFtRDMwb1BWodMSLuXDsr)
 Call ID: toolu_01VPFtRDMwb1BWodMSLuXDsr
  Args:
    end_date: 2024-05-09
    location: Basel
    price_tier: Economy
    start_date: 2024-05-02
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 1}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': 'The cheapest available option is the economy class rental with Europcar.', 'type': 'text'}, {'id': 'toolu_01NczhWtTH5TtoZ7RvJAPS11', 'input': {'rental_id': 1}, 'name': 'book_car_rental', 'type': 'tool_use'}]
Tool Calls:
  book_car_rental (toolu_01NczhWtTH5TtoZ7RvJAPS11)
 Call ID: toolu_01NczhWtTH5TtoZ7RvJAPS11
  Args:
    rental_id: 1
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Cool so now what recommendations do you have on excursions?
==================================[1m Ai Message [0m==================================

[{'text': 'Great, let me look into some recommended excursions and activities to do during your week-long stay in Basel:', 'type': 'text'}, {'id': 'toolu_01CdRKsURqjvbTtLyBMQcQtM', 'input': {'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01CdRKsURqjvbTtLyBMQcQtM)
 Call ID: toolu_01CdRKsURqjvbTtLyBMQcQtM
  Args:
    location: Basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[{"id": 1, "name": "Basel Minster", "location": "Basel", "keywords": "landmark, history", "details": "Visit the historic Basel Minster, a beautiful Gothic cathedral.", "booked": 0}, {"id": 2, "name": "Kunstmuseum Basel", "location": "Basel", "keywords": "art, museum", "details": "Explore the extensive art collection at the Kunstmuseum Basel.", "booked": 0}, {"id": 8, "name": "Basel Zoo", "location": "Basel", "keywords": "wildlife, zoo", "details": "Spend a day exploring the diverse animal exhibits at Basel Zoo.", "booked": 0}]
==================================[1m Ai Message [0m==================================

Here are some top recommendations for things to do in Basel:

1. Basel Minster - This Gothic cathedral is a major landmark and architectural highlight of the city. You can explore the interior and climb to the top for panoramic views.

2. Kunstmuseum Basel - One of the largest and most important museums in Switzerland, housing an impressive art collection from the 15th century to the present. 

3. Basel Zoo - A great family-friendly activity, the Basel Zoo has exhibits with over 6,000 animals and 600 species.

Some other potential options I could look into are day trips into nearby areas of Switzerland or France, guided city tours, museum passes, river cruises along the Rhine, or culinary experiences.

Let me know if any of those Basel recommendations pique your interest or if you'd like me to search for other types of activities! I'm happy to provide more details as well.
================================[1m Human Message [0m=================================

Are they available while I'm there?
==================================[1m Ai Message [0m==================================

[{'text': 'Good call to check availability for those recommended Basel activities during your specific travel dates. Let me look into that:', 'type': 'text'}, {'id': 'toolu_01UzDAdDTvDWz1HQnewcNPho', 'input': {'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01UzDAdDTvDWz1HQnewcNPho)
 Call ID: toolu_01UzDAdDTvDWz1HQnewcNPho
  Args:
    location: Basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[{"id": 1, "name": "Basel Minster", "location": "Basel", "keywords": "landmark, history", "details": "Visit the historic Basel Minster, a beautiful Gothic cathedral.", "booked": 0}, {"id": 2, "name": "Kunstmuseum Basel", "location": "Basel", "keywords": "art, museum", "details": "Explore the extensive art collection at the Kunstmuseum Basel.", "booked": 0}, {"id": 8, "name": "Basel Zoo", "location": "Basel", "keywords": "wildlife, zoo", "details": "Spend a day exploring the diverse animal exhibits at Basel Zoo.", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': 'The Basel Minster, Kunstmuseum Basel art museum, and Basel Zoo all appear to be available general attractions during your dates of May 2nd - May 9th in Basel.\n\nTo double check potential closures or guide availability, let me consult the policies:', 'type': 'text'}, {'id': 'toolu_011e7DtWGwQiU3AnntgCMc9r', 'input': {'query': 'basel attraction closures and hours'}, 'name': 'lookup_policy', 'type': 'tool_use'}]
Tool Calls:
  lookup_policy (toolu_011e7DtWGwQiU3AnntgCMc9r)
 Call ID: toolu_011e7DtWGwQiU3AnntgCMc9r
  Args:
    query: basel attraction closures and hours
=================================[1m Tool Message [0m=================================
Name: lookup_policy


## Booking and Cancellation

1. How can I change my booking?
    * The ticket number must start with 724 (SWISS ticket no./plate).
    * The ticket was not paid for by barter or voucher (there are exceptions to voucher payments; if the ticket was paid for in full by voucher, then it may be possible to rebook online under certain circumstances. If it is not possible to rebook online because of the payment method, then you will be informed accordingly during the rebooking process).
    * There must be an active flight booking for your ticket. It is not possible to rebook open tickets or tickets without the corresponding flight segments online at the moment.
    * It is currently only possible to rebook outbound (one-way) tickets or return tickets with single flight routes (point-to-point).
2. Which tickets/bookings cannot be rebooked online currently?
    * Bookings containing flight segments with other airlines
    * Bookings containing reservations, where a ticket has not yet been issued
    * Bookings with several valid tickets for the same person and route
    * Tickets with a status other than O (open) (A)
    * Bookings with segments with a status other than OK (e.g. containing flight segments with the status Waitlist) (HK|RR)
    * Tickets that do not display the tariff calculation (IT tickets)
    * Bookings that contain special services (e.g. transportation of animals/transportation of medica ... (truncated)
==================================[1m Ai Message [0m==================================

The company policies don't mention any specific closures or restricted hours for the major Basel attractions like the Minster cathedral, Kunstmuseum art museum or the zoo during early May. 

These seem to be year-round attractions that should be open and available to visit during your dates of May 2nd through 9th in Basel. The Basel Minster and museums may have slightly reduced hours on certain days, but barring any temporary closures, you should be able to visit and explore them while you're there.

Let me know if you'd like any additional details on hours, admission fees, guided tours etc. for booking purposes. Or if you'd prefer to look into other excursion options in the Basel region during your stay. I'm happy to provide more thorough recommendations!
================================[1m Human Message [0m=================================

interesting - i like the museums, what options are there? 
==================================[1m Ai Message [0m==================================

[{'text': 'Sure, let me look into some of the top museum options in Basel that could be good to visit during your stay:', 'type': 'text'}, {'id': 'toolu_01A39iRoJxQwSmtPiGq6SFcZ', 'input': {'keywords': 'museum', 'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01A39iRoJxQwSmtPiGq6SFcZ)
 Call ID: toolu_01A39iRoJxQwSmtPiGq6SFcZ
  Args:
    keywords: museum
    location: Basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[{"id": 2, "name": "Kunstmuseum Basel", "location": "Basel", "keywords": "art, museum", "details": "Explore the extensive art collection at the Kunstmuseum Basel.", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': 'The Kunstmuseum Basel, which I mentioned earlier, is definitely one of the top museums to consider. Some key details:\n\n- Kunstmuseum Basel - One of the largest and most important art museums in Switzerland featuring an excellent collection of paintings, drawings, sculptures and installations from the 15th century to present day. Highlights include works by Holbein, Witz, Cranach, Gauguin, Cézanne, Monet, van Gogh and Picasso.\n\nSince that search only returned one museum recommendation, let me expand to get some other options:', 'type': 'text'}, {'id': 'toolu_01626qCHRju7TLJoa5QctFn1', 'input': {'keywords': 'museum, arts, culture', 'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01626qCHRju7TLJoa5QctFn1)
 Call ID: toolu_01626qCHRju7TLJoa5QctFn1
  Args:
    keywords: museum, arts, culture
    location: Basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[{"id": 2, "name": "Kunstmuseum Basel", "location": "Basel", "keywords": "art, museum", "details": "Explore the extensive art collection at the Kunstmuseum Basel.", "booked": 0}]
==================================[1m Ai Message [0m==================================

Unfortunately that broader search didn't return any additional museum options in Basel in my database. However, some other top museums I could recommend based on research include:

- Basel Paper Mill Museum - Showcases the history of papermaking with working mills and exhibits
- Museum of Cultures - Ethnographic museum with artifacts from around the world 
- Cartoon Museum - Dedicated to comics, caricature and animated films

The Kunstmuseum does seem to be the premier art museum, but Basel has several niche museums covering other cultural topics if you want some variety.

Let me know if you'd like me to look into tickets, hours, or any other details to plan out visiting a few of these museums during your stay! I'm happy to provide more information.
================================[1m Human Message [0m=================================

OK great pick one and book it for my second day there.
==================================[1m Ai Message [0m==================================

[{'text': "Sounds good, let's book an excursion for your second day in Basel on May 3rd.\n\nBased on the museum options, the Kunstmuseum Basel does seem like the premier art museum to visit. Let me go ahead and book that:", 'type': 'text'}, {'id': 'toolu_01YLyWZ9WvKDaYm88hg3xZZe', 'input': {'recommendation_id': 2}, 'name': 'book_excursion', 'type': 'tool_use'}]
Tool Calls:
  book_excursion (toolu_01YLyWZ9WvKDaYm88hg3xZZe)
 Call ID: toolu_01YLyWZ9WvKDaYm88hg3xZZe
  Args:
    recommendation_id: 2
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y

```
# Part 3 Review¶
Much better! Our agent is now working well - check out a LangSmith trace of our latest run to inspect its work! You may be satisfied with this design. The code is contained, and it's behaving as desired.

One problem with this design is that we're putting a lot of pressure on a single prompt. If we want to add more tools, or if each tool gets more complicated (more filters, more business logic constraining behavior, etc), it's likely the tool usage and overall behavior of the bot will start to suffer.

In the next section, we show how you can take more control over different user experiences by routing to specialist agents or sub-graphs based on the user's intent.

# 🌟 **Understanding Conditional Interrupts and Graph Design in Chatbots**  

This guide will explain the concept of **Conditional Interrupts** and how to **define a graph** to manage chatbot workflows effectively. We'll break it down into easy-to-understand sections with real-world examples, Python code explanations, and visual cues.  

---

## ✈️ **Real-World Example: Airline Customer Support Chatbot**  
Imagine you're building a chatbot for **Swiss Airlines**. The chatbot can:  
- 🔍 Search flights, hotels, and cars (read-only tasks).  
- ✏️ Book, update, or cancel reservations (data-modifying tasks).  

Since booking or canceling involves critical user data, we want the **user’s confirmation** before performing such actions. This is where **Conditional Interrupts** come in!  

---

## 🧭 **What is a Conditional Interrupt?**  

💡 **Definition:**  
A *Conditional Interrupt* allows a chatbot to **pause** before executing certain actions (like booking a hotel) to get the **user's approval**.  

### 💬 **Why is this important?**  
1. ✅ **User Control:** Users stay in charge of sensitive actions.  
2. 🔄 **Smooth Flow:** Read-only tasks run automatically, without interruptions.  
3. 🛡 **Error Prevention:** Prevents unintended bookings or cancellations.  

---

## 🗂 **Step-by-Step Breakdown of the Graph Structure**  

We will create a **graph** (workflow) that:  
- Splits the chatbot's actions into **safe** (read-only) and **sensitive** (data-modifying) nodes.  
- Interrupts only when **sensitive tools** are about to execute.  

---

## 📝 **1. Define Graph State**  

### 🔍 **What is Graph State?**  
The **state** holds all the information (e.g., user queries, user info) that the chatbot needs during a conversation.  

### 🧑‍💻 **Python Code: Graph State Definition**  

```python
from typing import Annotated
from langchain_core.runnables import Runnable, RunnableConfig
from langchain_core.prompts import ChatPromptTemplate
from langgraph.graph.message import AnyMessage, add_messages
from typing_extensions import TypedDict

# ✅ State holds the conversation messages and user info
class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str
```

### 🖋 **Code Explanation:**  
- ✅ `State`: Defines a dictionary with two keys:  
  - `messages`: Stores chat messages between the user and the assistant.  
  - `user_info`: Stores user-specific data (like flight details).  
- 🏷 **`Annotated`** ensures that `messages` is updated as the conversation flows.  

---

## 🧱 **2. Define the Graph Structure**  

### ⚡ **Key Concepts in Graph Structure:**  
- **Nodes:** Represent different tasks (e.g., fetching user info, booking hotels).  
- **Edges:** Define the flow between nodes.  
- **Conditional Edges:** Let the graph decide the next step based on user input.  

---

### 🌟 **Python Code: Defining Graph with Conditional Interrupts**  

```python
from langgraph.graph import StateGraph
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import tools_condition

# ✅ Initialize the graph
builder = StateGraph(State)

# 🛫 Fetch user flight information first
def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")

# 🧑‍💼 Add assistant and tool nodes
builder.add_node("assistant", Assistant(part_3_assistant_runnable))
builder.add_node("safe_tools", create_tool_node_with_fallback(part_3_safe_tools))
builder.add_node("sensitive_tools", create_tool_node_with_fallback(part_3_sensitive_tools))

builder.add_edge("fetch_user_info", "assistant")

# 🔀 Conditionally route tools based on sensitivity
def route_tools(state: State):
    next_node = tools_condition(state)
    if next_node == END:
        return END
    ai_message = state["messages"][-1]
    first_tool_call = ai_message.tool_calls[0]
    if first_tool_call["name"] in sensitive_tool_names:
        return "sensitive_tools"
    return "safe_tools"

builder.add_conditional_edges("assistant", route_tools, ["safe_tools", "sensitive_tools", END])
builder.add_edge("safe_tools", "assistant")
builder.add_edge("sensitive_tools", "assistant")

# 💾 Save memory state and compile
memory = MemorySaver()
part_3_graph = builder.compile(
    checkpointer=memory,
    interrupt_before=["sensitive_tools"],  # 🔔 Interrupt before sensitive tools
)
```

---

### 💡 **Code Walkthrough:**  
1. **Initialize Graph:**  
   - `StateGraph(State)`: Starts a graph with our predefined state.  
2. **Fetch User Info:**  
   - The **first node** fetches user flight details, giving the assistant context without extra user input.  
3. **Assistant & Tools:**  
   - **Safe Tools:** Handled without user approval (e.g., searching flights).  
   - **Sensitive Tools:** Pauses for user approval (e.g., booking/canceling hotels).  
4. **Conditional Routing:**  
   - **`route_tools()`** decides which node to go to next, based on the tool's sensitivity.  
5. **Memory Management:**  
   - **`MemorySaver()`** keeps track of the conversation state.  
6. **Interrupt Before Sensitive Actions:**  
   - The graph **halts** before executing sensitive actions, asking for user confirmation.  

---

## 🤖 **3. Testing the Chatbot: Example Conversation**  

Let’s see how the chatbot interacts with a user while respecting conditional interrupts.  

### 📝 **Sample Conversation with Conditional Interrupts:**  

```python
tutorial_questions = [
    "Hi there, what time is my flight?",
    "Can I update my flight to leave today?",
    "Update my flight to next week then.",
    "Book an affordable hotel for 7 days.",
    "Go ahead and book the recommended hotel.",
    "Now for a car, what options do I have?",
    "Book the cheapest car for 7 days.",
]

for question in tutorial_questions:
    events = part_3_graph.stream({"messages": ("user", question)}, config, stream_mode="values")
    for event in events:
        _print_event(event, _printed)
    snapshot = part_3_graph.get_state(config)
    while snapshot.next:
        user_input = input("Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changes.\n\n")
        if user_input.strip() == "y":
            part_3_graph.invoke(None, config)
        else:
            part_3_graph.invoke({"messages": [("user", f"API call denied. Reason: '{user_input}'")]}, config)
```

---

### 🖋 **Explanation:**  
- 💬 The chatbot responds to user queries about flights, hotels, and cars.  
- 🔔 **Before booking** a hotel or car, it **pauses** to ask for **user approval**.  
- 📝 If the user **denies** the action, the chatbot will adjust accordingly.  

---

## 🎯 **4. Key Takeaways from Part 3 (Conditional Interrupts)**  

✅ **User-First Design:** Users approve sensitive actions.  
✅ **Efficient Automation:** Safe tasks are automated without interruptions.  
✅ **Scalable Structure:** Easily add more tools and conditions.  
✅ **Improved User Experience:** Smooth conversation flow with minimal disruptions.  

---

## 🎡 **Real-World Use Cases**  

💼 **Banking Bots:** Pauses before transferring money or closing accounts.  
🛒 **E-commerce Assistants:** Seeks approval before placing large orders.  
🏥 **Healthcare Chatbots:** Confirms before booking appointments or sharing sensitive medical data.  
🏨 **Travel Booking Assistants:** Pauses before booking hotels, flights, or cars.  

---

## 🚀 **Conclusion**  

Conditional interrupts bring the **perfect balance** between automation and user control. By thoughtfully structuring chatbot workflows using **graph models**, you ensure users have a **seamless, secure, and satisfying** experience.  

---

✨ **In the next section**, we’ll explore how to manage complex workflows by introducing **specialist agents** and **sub-graphs** to handle different user intents more effectively.  

---

💬 *Let me know if you’d like more examples or deeper explanations on any specific part!*

# Or unzasohail019@gmail.com response:

# 🚀 Understanding Graph-Based AI Assistant Workflow  

In this guide, we’ll break down the concept of defining a **graph-based AI workflow**, explain it in an easy-to-understand manner, and provide real-world examples. By the end, you’ll have a clear picture of how AI assistants manage tasks using structured workflows.

---

## 📌 What is a Graph in AI Workflows?  

A **graph** in AI workflows is a **structured representation of how an assistant processes user inputs and executes tasks**. It consists of **nodes** (representing tasks) and **edges** (showing how tasks are connected).  

### 🔍 Real-World Example:  
Imagine a **travel booking assistant** that helps users check flight details, modify bookings, and reserve hotels. Instead of handling everything in a linear way, it uses a **graph** to decide what step to take next based on the user's request.

---

## 🛠 Defining the AI Workflow Graph  

We define a **graph** to structure the decision-making process for our AI assistant.  

### 🏗 Steps to Build the Graph  

### 1️⃣ **Initialize the Graph**  
We start by **creating a graph object** using `StateGraph`, which represents the **flow of conversation and decision-making**.  

```python
from langgraph.graph import StateGraph

builder = StateGraph(State)
```

Here, `StateGraph(State)` initializes an AI workflow where different **states** (steps) will be defined.

---

### 2️⃣ **Fetching User Information**  
The AI needs **context** before responding. We define a **node** to fetch the user’s flight information first.

```python
def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")
```

🔹 **Why?** This ensures the assistant **knows the user’s flight details** before making suggestions.

---

### 3️⃣ **Defining AI Assistant's Actions**  
Now, we define how the **assistant processes the user’s input**.

```python
builder.add_node("assistant", Assistant(part_3_assistant_runnable))
```

This node represents the **AI’s decision-making process**, where it determines what action to take next.

---

### 4️⃣ **Handling Different Tools**  
We separate tools into **safe** and **sensitive** categories:  

🔹 **Safe tools**: Actions that don’t modify bookings (e.g., checking flight status).  
🔹 **Sensitive tools**: Actions that **change bookings** (e.g., rescheduling a flight).

```python
builder.add_node("safe_tools", create_tool_node_with_fallback(part_3_safe_tools))
builder.add_node("sensitive_tools", create_tool_node_with_fallback(part_3_sensitive_tools))
```

💡 **Why separate tools?** This ensures that actions affecting user bookings require confirmation before execution.

---

### 5️⃣ **Routing Logic for AI Decisions**  
Now, we decide whether the assistant should use **safe tools or sensitive tools**.

```python
def route_tools(state: State):
    next_node = tools_condition(state)
    if next_node == END:
        return END
    ai_message = state["messages"][-1]
    first_tool_call = ai_message.tool_calls[0]
    if first_tool_call["name"] in sensitive_tool_names:
        return "sensitive_tools"
    return "safe_tools"

builder.add_conditional_edges(
    "assistant", route_tools, ["safe_tools", "sensitive_tools", END]
)
```

✅ **This logic ensures:**  
- If no tool is needed, the AI responds to the user.  
- If a **sensitive tool** is needed, the user is **asked for approval** before execution.  

---

### 🔎 **Real-World Use Case: AI-Powered Travel Assistant**  

💡 **Scenario:**  
A user interacts with an AI assistant to manage their travel bookings.

### 📝 **Example Conversation Flow**  

| **User Query** | **AI Response** | **Graph Decision** |
|--------------|--------------|----------------|
| “What time is my flight?” | AI retrieves flight details. | Uses `safe_tools`. |
| “Can I change my flight to later today?” | AI finds new options but asks for approval before changing. | Uses `sensitive_tools`. |
| “Can you book a hotel for me?” | AI books a hotel if available. | Uses `safe_tools`. |
| “Book a rental car for 7 days.” | AI reserves a car. | Uses `safe_tools`. |
| “Change my flight to next week.” | AI asks for confirmation before updating the booking. | Uses `sensitive_tools`. |

---

## 🛑 **User Approval Before Critical Actions**  

One key improvement in this design is that **sensitive actions require user approval** before execution.

```python
interrupt_before=["sensitive_tools"]
```

🛑 **Why is this important?**  
- Prevents accidental modifications.  
- Gives users control over sensitive changes.  

---

## ✅ **Final Thoughts: Benefits of Using Graphs in AI Assistants**  

📌 **Improved Decision-Making** – The assistant follows a structured **graph-based approach** rather than responding blindly.  
📌 **Better User Experience** – Users don’t have to repeat themselves; the AI already has their information.  
📌 **Control Over Critical Actions** – Users must **approve sensitive changes**, preventing accidental modifications.  
📌 **Scalability** – The graph can easily be **extended with more tools and logic** for better AI performance.  

---

## 🎯 **Next Steps: Enhancing the AI Assistant**  

🚀 The next step is to **handle more complex scenarios** by introducing **sub-graphs** for specialized tasks. This allows the AI to become even **smarter and more efficient**. Stay tuned for the next section, where we improve user experiences by **routing requests to specialized agents**.

---

### 🔗 **Further Reading**  
- 🔍 Learn more about **Graph-Based AI Workflows** in [LangGraph Documentation](https://github.com/langchain-ai/langgraph).  
- 📚 Deep dive into **AI Agents and Tools** for enhancing conversational AI.  

💡 **Would you like me to help implement a similar AI assistant for your project? Let me know!** 🚀