
# Part 2: Add Confirmation¶ 

When an assistant takes actions on behalf of the user, the user should (almost) always have the final say on whether to follow through with the actions. Otherwise, any small mistake the assistant makes (or any prompt injection it succombs to) can cause real damage to the user.

In this section, we will use interrupt_before to pause the graph and return control to the user before executing any of the tools.

Your graph will look something like the following:



As before, start by defining the state:

# State & Assistant¶
Our graph state and LLM calling is nearly identical to Part 1 except Exception:

We've added a user_info field that will be eagerly populated by our graph
We can use the state directly in the Assistant object rather than using the configurable params

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
# You could also use OpenAI or another model, though you will likely have
# to adapt the prompts
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

part_2_tools = [
    TavilySearchResults(max_results=1),
    fetch_user_flight_information,
    search_flights,
    lookup_policy,
    update_ticket_to_new_flight,
    cancel_ticket,
    search_car_rentals,
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
    search_hotels,
    book_hotel,
    update_hotel,
    cancel_hotel,
    search_trip_recommendations,
    book_excursion,
    update_excursion,
    cancel_excursion,
]
```
part_2_assistant_runnable = assistant_prompt | llm.bind_tools(part_2_tools)
API Reference: ChatAnthropic | TavilySearchResults | ChatPromptTemplate | Runnable | RunnableConfig | ChatOpenAI | add_messages



# Define Graph¶ 
Now, create the graph. Make 2 changes from part 1 to address our previous concerns.

Add an interrupt before using a tool
Explicitly populate the user state within the first node so the assistant doesn't have to use a tool just to learn about the user.

```python
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
builder.add_node("assistant", Assistant(part_2_assistant_runnable))
builder.add_node("tools", create_tool_node_with_fallback(part_2_tools))
builder.add_edge("fetch_user_info", "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition,
)
builder.add_edge("tools", "assistant")

memory = MemorySaver()
part_2_graph = builder.compile(
    checkpointer=memory,
    # NEW: The graph will always halt before executing the "tools" node.
    # The user can approve or reject (or even alter the request) before
    # the assistant continues
    interrupt_before=["tools"],
)
API Reference: MemorySaver | StateGraph | tools_condition


from IPython.display import Image, display

try:
    display(Image(part_2_graph.get_graph(xray=True).draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass

```

# ✈️ **Part 2: Add Confirmation**  

When an assistant takes actions on behalf of a user, it’s essential that the user **confirms** those actions. This step ensures that no unintended actions occur due to mistakes or malicious inputs. This is especially important in real-world applications like booking flights, managing financial transactions, or making purchases.

---

## 📝 **Why Add Confirmation?**  
- ✅ Prevents unintended or incorrect actions.  
- 🔒 Protects the user from potential security risks.  
- 💬 Improves user trust by giving them control over critical actions.  

**Real-World Example:**  
Imagine booking a flight. If the assistant updates your ticket without asking for confirmation, you might end up with incorrect dates or times. Adding a confirmation step ensures **you approve** changes before they happen.

---

## 🔍 **Key Concepts in This Section**  
1. 🌐 **State Definition & Assistant Class**  
2. 🛠️ **Adding Tools for User Actions**  
3. 🛑 **Interrupt Before Execution for Confirmation**  
4. 🗂️ **Defining the Graph with Control Flow**  
5. 💾 **Using MemorySaver for Persistent State**  

---

## 1️⃣ 🌐 **State Definition & Assistant Class**  

### 🎯 **Purpose**:  
- The **state** stores important information (like user messages and user details).  
- The **assistant** processes user messages using a language model and decides on the next steps.

### 💻 **Code Example and Explanation:**

```python
from typing import Annotated
from langchain_core.runnables import Runnable, RunnableConfig
from langgraph.graph.message import AnyMessage, add_messages
from typing_extensions import TypedDict

# ✅ Defining the State to store messages and user information
class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str


# ✅ Assistant class that processes user messages
class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable  # Store the runnable (LLM + prompt)

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)  # Call the model with the current state
            # If no valid response, ask the model to respond again
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

### 🔍 **Explanation:**
- **State Class:**  
  - Stores all user messages (`messages`) and their information (`user_info`).  
- **Assistant Class:**  
  - The assistant uses a **language model** to process user queries.  
  - If the model returns an **empty** or **invalid** response, it re-prompts until a valid response is generated.

---

## 2️⃣ 🛠️ **Adding Tools for User Actions**  

### 🎯 **Purpose**:  
Tools allow the assistant to perform **real-world tasks** like searching flights, booking hotels, or renting cars.

### 💻 **Code Example:**

```python
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

# ✅ Define the language model (LLM) - Here, Claude Sonnet is used
llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)

# ✅ Assistant's prompt that guides its responses
assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            " Use tools to search flights, policies, and other info. Be persistent in searches."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

# ✅ Tools that the assistant can use for user tasks
part_2_tools = [
    TavilySearchResults(max_results=1),
    fetch_user_flight_information,
    search_flights,
    update_ticket_to_new_flight,
    cancel_ticket,
    search_car_rentals,
    book_car_rental,
    search_hotels,
    book_hotel,
    search_trip_recommendations,
    book_excursion,
]
```

### 🔍 **Explanation:**
- The **assistant_prompt** provides context for the assistant’s responses, mentioning the user and current time.  
- The **tools** list includes different operations like searching flights, booking hotels, and managing car rentals.

---

## 3️⃣ 🛑 **Interrupt Before Execution for Confirmation**  

### 🎯 **Purpose**:  
Before performing critical tasks like **booking** or **canceling**, the assistant will **pause** and ask the user for **confirmation**.

### 💻 **Code Example:**

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph, START
from langgraph.prebuilt import tools_condition

# ✅ Create a stateful graph
builder = StateGraph(State)

# ✅ Fetch user information before any assistant action
def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")
builder.add_node("assistant", Assistant(part_2_assistant_runnable))
builder.add_node("tools", create_tool_node_with_fallback(part_2_tools))
builder.add_edge("fetch_user_info", "assistant")
builder.add_conditional_edges("assistant", tools_condition)
builder.add_edge("tools", "assistant")

# ✅ Add a memory saver to persist graph state
memory = MemorySaver()

# 🚨 The graph will pause (interrupt) before executing the "tools" node for user confirmation
part_2_graph = builder.compile(
    checkpointer=memory,
    interrupt_before=["tools"],
)
```

### 🔍 **Explanation:**
- The **interrupt_before=["tools"]** ensures that **user approval** is required before performing any critical action.  
- **MemorySaver** stores conversation progress, allowing the session to resume if interrupted.

---

## 4️⃣ 🗂️ **Defining the Graph with Control Flow**  

### 🎯 **Purpose**:  
Control flow ensures that each part of the assistant runs **in sequence** and follows the correct order.

### 💻 **Graph Visualization (Optional)**:

```python
from IPython.display import Image, display

try:
    display(Image(part_2_graph.get_graph(xray=True).draw_mermaid_png()))
except Exception:
    pass
```

---

## 5️⃣ 💾 **Using MemorySaver for Persistent State**  

### 🎯 **Purpose**:  
- Keeps the assistant's progress **intact** even if the process is interrupted.  
- Essential for **long-running tasks** where users may take time to respond.

---

## 🌟 **Real-World Use Case**  

### 🏨 **Scenario: Booking a Hotel**  
Imagine you're planning a trip. You ask your assistant to book a hotel. Here's how the confirmation step saves the day:

1️⃣ **You:** "Book a hotel for 7 days."  
2️⃣ **Assistant:** *"I found a hotel matching your criteria. Should I book it now?"*  
3️⃣ **You:** "Wait, I want to check other options first."  

Without this **confirmation**, the assistant might have booked a non-refundable room. This **extra step** prevents **financial loss** and **misunderstandings**.

---

## 🎉 **Summary**  
In this section, we:  
- ✅ Defined a state with user information.  
- ✅ Created an assistant that processes user messages using a language model.  
- ✅ Added tools for real-world actions like flight booking and hotel searches.  
- 🚨 Introduced an **interrupt_before** mechanism to **pause for user confirmation** before executing critical actions.  
- 💾 Used **MemorySaver** for persistent state management.  

---

## 💡 **Key Takeaways:**  
- Always **confirm** before critical actions.  
- Use **state management** to keep track of user information.  
- **Control flow** ensures logical and safe progression of tasks.  
- **Persistent memory** is crucial for real-time applications where user interaction spans longer periods.  

---

Let me know if you need further clarifications or more real-world examples! 😊✨

---
# Or unzasohail019@gmail.com response:
# 🛑 Part 2: Adding Confirmation Before Execution  

When building AI assistants that perform actions on behalf of users, it is **crucial** to have a confirmation step before executing any significant action. This prevents unwanted operations and ensures that users have control over the process.  

In this guide, we will **deeply** explore how to implement **interrupt_before** to **pause execution** before an action is taken. We'll also explain the **purpose of each line of code** and provide **real-world use cases** where this concept is applicable.  

---

## 🔍 Why Is Confirmation Important?  

If an AI assistant **executes actions automatically**, it may:  
✅ Perform unintended operations (e.g., book a flight instead of a hotel).  
✅ Be vulnerable to **prompt injection attacks** (malicious users tricking the assistant).  
✅ Lead to **user dissatisfaction** due to lack of control.  

### 🏢 **Real-World Use Case**  
Imagine an **AI travel assistant** that books flights, hotels, and cars for users. Without confirmation, the assistant might book a **wrong date or city**, leading to **financial loss**. By **pausing execution** and asking for confirmation, the user can **review the action** before it is completed.  

---

# 📌 Step 1: Define State & Assistant  

Before creating the assistant, we define a **state object** that holds **user messages** and **user info**.  

### 📝 **Code Example: Defining the State**  
```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages

class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]  # Stores chat history
    user_info: str  # Stores user details (e.g., flight information)
```
### 🧐 **Explanation**  
- `TypedDict`: Defines a dictionary where keys have specific data types.  
- `messages`: Holds a list of messages between user and assistant.  
- `user_info`: Stores user details **before** the assistant takes any action.  

---

### 📝 **Code Example: Creating the Assistant**  
```python
class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)
            # If LLM returns an empty response, ask it again.
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
### 🧐 **Explanation**  
- `self.runnable.invoke(state)`: Calls the AI model to generate a response.  
- **Handles cases where AI returns an empty response** by **re-prompting** the model.  
- **Returns** a dictionary with the new **chat messages**.  

---

# 📌 Step 2: Setting Up the AI Model  

The assistant uses **Anthropic Claude-3 Sonnet** to process user requests.  

### 📝 **Code Example: Initializing the Model**  
```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)
```
### 🧐 **Explanation**  
- `"claude-3-sonnet-20240229"`: **A powerful AI model** for handling complex queries.  
- `temperature=1`: Increases **randomness** in responses for a **natural feel**.  

---

# 📌 Step 3: Defining AI Instructions  

We define **system instructions** to guide the AI assistant on how to behave.  

### 📝 **Code Example: Defining AI Instructions**  
```python
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            "Use the provided tools to search for flights, policies, and assist with queries. "
            "If a search returns no results, expand the query before giving up."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```
### 🧐 **Explanation**  
- **Defines AI's role** as a **Swiss Airlines assistant**.  
- If the search **fails**, AI should **retry** with broader parameters.  
- Uses `{user_info}` to **personalize responses** based on user details.  
- `{time}` ensures AI is **aware of the current time**.  

---

# 📌 Step 4: Adding Tools for Execution  

The assistant **interacts with external tools** to book flights, hotels, cars, etc.  

### 📝 **Code Example: Defining Tools**  
```python
from langchain_community.tools.tavily_search import TavilySearchResults

part_2_tools = [
    TavilySearchResults(max_results=1),  # Search tool
    fetch_user_flight_information,
    search_flights,
    lookup_policy,
    update_ticket_to_new_flight,
    cancel_ticket,
    search_car_rentals,
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
    search_hotels,
    book_hotel,
    update_hotel,
    cancel_hotel,
    search_trip_recommendations,
    book_excursion,
    update_excursion,
    cancel_excursion,
]
```
### 🧐 **Explanation**  
- **Defines a list of tools** for **flight, hotel, and car rental management**.  
- The assistant **binds these tools** to interact with real-world services.  

---

# 📌 Step 5: Defining the Graph  

The **graph structure** determines the **execution flow** of the assistant.  

### 📝 **Code Example: Setting Up the Graph**  
```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

builder = StateGraph(State)

def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

builder.add_node("fetch_user_info", user_info)
builder.add_edge("START", "fetch_user_info")
builder.add_node("assistant", Assistant(part_2_assistant_runnable))
builder.add_node("tools", create_tool_node_with_fallback(part_2_tools))
builder.add_edge("fetch_user_info", "assistant")
builder.add_conditional_edges("assistant", tools_condition)
builder.add_edge("tools", "assistant")
```
### 🧐 **Explanation**  
- `StateGraph(State)`: Creates a **graph structure** to define execution order.  
- `fetch_user_info`: **Retrieves user details** before AI takes any action.  
- **Edges (`add_edge`)** define the sequence in which nodes execute.  

---

# 📌 Step 6: Adding Confirmation Before Execution  

The **interrupt_before** parameter **pauses execution** before an action is performed.  

### 📝 **Code Example: Adding Confirmation Step**  
```python
memory = MemorySaver()
part_2_graph = builder.compile(
    checkpointer=memory,
    interrupt_before=["tools"],  # Pause execution before calling external tools
)
```
### 🧐 **Explanation**  
- `interrupt_before=["tools"]`: **Stops execution** before using any external tools.  
- **User must approve or modify the action** before it is executed.  

---

# 🎯 **Final Thoughts**  

### ✅ **What We Learned**  
✔ The importance of **confirmation** before executing AI-driven actions.  
✔ How to define **state, assistant, tools, and execution graphs**.  
✔ How to **pause execution** using `interrupt_before`.  

### 🌎 **Real-World Applications**  
📍 **Chatbots** (prevent unwanted bookings).  
📍 **Automated customer support** (prevent unauthorized cancellations).  
📍 **AI-powered assistants** (ensure user approval for financial transactions).  

🔗 **Next Steps**: Optimize the assistant by improving search capabilities! 🚀

# Example Conversation¶ 

Now it's time to try out our newly revised chatbot! Let's run it over the following list of dialog turns.


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


_printed = set()
# We can reuse the tutorial questions from part 1 to see how it does.
for question in tutorial_questions:
    events = part_2_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
    snapshot = part_2_graph.get_state(config)
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
            result = part_2_graph.invoke(
                None,
                config,
            )
        else:
            # Satisfy the tool invocation by
            # providing instructions on the requested changes / change of mind
            result = part_2_graph.invoke(
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
        snapshot = part_2_graph.get_state(config)

```

```js
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

The next available option is great
==================================[1m Ai Message [0m==================================

[{'text': "Got it, let's update your ticket to the next available Swiss Air flight from Paris (CDG) to Basel (BSL) next week.\n\nBased on the search results, the next available flight after your originally scheduled one is:\n\nFlight No: LX0112\nDeparture: 2024-05-01 20:37 (CDG) \nArrival: 2024-05-01 22:07 (BSL)\nFlight ID: 19233\n\nLet me confirm the policy allows updating to this new flight date and time with your Economy Flex ticket.", 'type': 'text'}, {'id': 'toolu_01YBwigKSeqeELNRa66B8iST', 'input': {'query': 'changing economy flex ticket to different date'}, 'name': 'lookup_policy', 'type': 'tool_use'}]
Tool Calls:
  lookup_policy (toolu_01YBwigKSeqeELNRa66B8iST)
 Call ID: toolu_01YBwigKSeqeELNRa66B8iST
  Args:
    query: changing economy flex ticket to different date
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

what about lodging and transportation?
==================================[1m Ai Message [0m==================================

[{'text': 'Sure, let me help you with arranging lodging and transportation for your updated travel dates in Basel next week.\n\nFor hotels, we can search and book accommodations during your stay:', 'type': 'text'}, {'id': 'toolu_01PBJ6rZ2P9tvVLWPt5Nrck7', 'input': {'checkin_date': '2024-05-01', 'checkout_date': '2024-05-02', 'location': 'Basel'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01PBJ6rZ2P9tvVLWPt5Nrck7)
 Call ID: toolu_01PBJ6rZ2P9tvVLWPt5Nrck7
  Args:
    checkin_date: 2024-05-01
    checkout_date: 2024-05-02
    location: Basel
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Yeah i think i'd like an affordable hotel for my week-long stay (7 days). And I'll want to rent a car.
==================================[1m Ai Message [0m==================================

[{'text': 'Got it, let me find an affordable hotel option in Basel for your full 7-night stay from May 1st to May 8th, as well as book a rental car for that week.\n\nHotels:', 'type': 'text'}, {'id': 'toolu_01LxFFfzABYA5C2XeAHBdPoj', 'input': {'checkin_date': '2024-05-01', 'checkout_date': '2024-05-08', 'location': 'Basel', 'price_tier': 'Midscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01LxFFfzABYA5C2XeAHBdPoj)
 Call ID: toolu_01LxFFfzABYA5C2XeAHBdPoj
  Args:
    checkin_date: 2024-05-01
    checkout_date: 2024-05-08
    location: Basel
    price_tier: Midscale
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

OK could you place a reservation for your recommended hotel? It sounds nice.
==================================[1m Ai Message [0m==================================

[{'text': "Absolutely, let's go ahead and book the Holiday Inn Basel for your 7-night stay from May 1st to May 8th.", 'type': 'text'}, {'id': 'toolu_01LpFKBSD9bZFWdERcdDa2ak', 'input': {'hotel_id': 8}, 'name': 'book_hotel', 'type': 'tool_use'}]
Tool Calls:
  book_hotel (toolu_01LpFKBSD9bZFWdERcdDa2ak)
 Call ID: toolu_01LpFKBSD9bZFWdERcdDa2ak
  Args:
    hotel_id: 8
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

yes go ahead and book anything that's moderate expense and has availability.
==================================[1m Ai Message [0m==================================

[{'text': 'Sure, I can look into booking some moderate expense activities and excursions to round out your stay in Basel next week. Let me search for some recommendations:', 'type': 'text'}, {'id': 'toolu_018ZyVMrhFC53k2AoeB9k9ky', 'input': {'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_018ZyVMrhFC53k2AoeB9k9ky)
 Call ID: toolu_018ZyVMrhFC53k2AoeB9k9ky
  Args:
    location: Basel
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Now for a car, what are my options?
==================================[1m Ai Message [0m==================================

[{'text': "Sure, let's take another look at the rental car options for your 7-night stay in Basel from May 1st to May 8th.", 'type': 'text'}, {'id': 'toolu_01Kvt46tqAZKbE1Y4qAUYvPD', 'input': {'end_date': '2024-05-08', 'location': 'Basel', 'start_date': '2024-05-01'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_01Kvt46tqAZKbE1Y4qAUYvPD)
 Call ID: toolu_01Kvt46tqAZKbE1Y4qAUYvPD
  Args:
    end_date: 2024-05-08
    location: Basel
    start_date: 2024-05-01
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Awesome let's just get the cheapest option. Go ahead and book for 7 days
==================================[1m Ai Message [0m==================================

[{'text': "Sounds good, let's stick with the most affordable rental car option for your 7 day stay in Basel. \n\nI had previously booked the economy rental from Europcar for the dates of May 1st to May 8th. Here are the details:", 'type': 'text'}, {'id': 'toolu_01G5rH9LF9nmcz2C6JCUVfSf', 'input': {'rental_id': 1}, 'name': 'book_car_rental', 'type': 'tool_use'}]
Tool Calls:
  book_car_rental (toolu_01G5rH9LF9nmcz2C6JCUVfSf)
 Call ID: toolu_01G5rH9LF9nmcz2C6JCUVfSf
  Args:
    rental_id: 1
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Cool so now what recommendations do you have on excursions?
==================================[1m Ai Message [0m==================================

[{'text': 'Great, let me provide some moderate expense excursion and activity recommendations to fill out your itinerary for your week-long stay in Basel:', 'type': 'text'}, {'id': 'toolu_012iNuX9sMM9txeBSnjM7caz', 'input': {'keywords': 'basel, day trips', 'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_012iNuX9sMM9txeBSnjM7caz)
 Call ID: toolu_012iNuX9sMM9txeBSnjM7caz
  Args:
    keywords: basel, day trips
    location: Basel
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Are they available while I'm there?
==================================[1m Ai Message [0m==================================

[{'text': 'Good point, let me verify availability for those recommended excursions during your stay in Basel from May 1st to May 8th.', 'type': 'text'}, {'id': 'toolu_019wuQZVgGoNPcJDofm2zETY', 'input': {'location': 'Basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_019wuQZVgGoNPcJDofm2zETY)
 Call ID: toolu_019wuQZVgGoNPcJDofm2zETY
  Args:
    location: Basel
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

interesting - i like the museums, what options are there? OK great pick one and book it for my second day there.
==================================[1m Ai Message [0m==================================

[{'text': "Sounds good, let's book the Kunstmuseum Basel art museum for your second day in the city on May 2nd.", 'type': 'text'}, {'id': 'toolu_01F4EQx4PFJDcdHRFgSSVdEf', 'input': {'recommendation_id': 2}, 'name': 'book_excursion', 'type': 'tool_use'}]
Tool Calls:
  book_excursion (toolu_01F4EQx4PFJDcdHRFgSSVdEf)
 Call ID: toolu_01F4EQx4PFJDcdHRFgSSVdEf
  Args:
    recommendation_id: 2
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y

```
# Part 2 Review¶ 

Now our assistant was able to save a step to respond with our flight details. We also completely controlled which actions were performed. This all worked using LangGraph's interrupts and checkpointers. The interrupt pauses graph execution, its state safely persisted using your configured checkpointer. The user can then start it up at any time by running it with the right config.

See an example LangSmith trace to get a better sense of how the graph is running. Note from this trace that you typically resume a flow by invoking the graph with (None, config). The state is loaded from the checkpoint as if it never was interrupted.

This graph worked pretty well! We didn't really need to be involved in EVERY assistant action, though...

In the next section, we will reorganize our graph so that we can interrupt only on the "sensitive" actions that actually write to the database.

# 🌟 **Understanding Example Conversation in LangGraph with Confirmation and Interrupts**  

This guide will break down the **Example Conversation** concept, explaining it step by step in an easy-to-understand manner. We’ll use real-world examples, explain each line of code, and add relevant explanations of key concepts like **interrupts**, **checkpoints**, and **tool invocations** in LangGraph.  

---

## 🎯 **What Is This Concept About?**  

Imagine you have a chatbot that helps users book flights, hotels, or rental cars. When the bot takes actions like canceling a booking or updating flight information, you want the **user to confirm** before the action is executed.  

🔑 **Key Idea:**  
The **assistant should pause** before performing sensitive actions so the **user can approve** or modify the action.  

---

## ✈️ **Real-World Example**  

Think about **customer support for an airline**.  
- A customer asks the bot to cancel a flight.  
- The bot **pauses** and asks, "Are you sure you want to cancel your flight?"  
- The **customer confirms**, and the bot proceeds.  

This prevents **accidental cancellations** and ensures the **user stays in control**.  

---

## 💡 **Key Concepts Explained**  

### 🛑 **Interrupts**  
- Interrupts **pause the execution** of the chatbot before sensitive actions.  
- The user can **approve, deny, or modify** the action.  

### 💾 **Checkpoints**  
- Checkpoints **save the chatbot's progress** so it can **resume later** without starting over.  
- Useful when **user input is needed** before continuing.  

### 🛠 **Tool Invocation**  
- The assistant uses **tools** like `search_flights` or `cancel_ticket`.  
- Before executing these, the assistant **asks for user confirmation**.  

---

## 📝 **Code Breakdown and Explanation**  

Let’s break down the provided Python code **line by line**, explaining what each part does.

---

### ⚙️ **Step 1: Importing Required Libraries**  
```python
import shutil
import uuid
```
- **`shutil`**: Handles file operations (not directly used here but could be for managing data).  
- **`uuid`**: Generates **unique identifiers**. We’ll use this for the **thread ID**, ensuring each conversation session is unique.  

---

### 🔄 **Step 2: Preparing the Database and Configuration**  
```python
db = update_dates(db)  # Updates date fields in the database
thread_id = str(uuid.uuid4())  # Generates a unique thread ID for this session
```
- **`update_dates(db)`**: Updates the database dates so the chatbot works with fresh data.  
- **`thread_id`**: Every chatbot session needs a **unique identifier** so it can be paused and resumed independently.  

---

### 🏗 **Step 3: Configuration Setup**  
```python
config = {
    "configurable": {
        "passenger_id": "3442 587242",  # Identifies the user (passenger)
        "thread_id": thread_id,  # Links this session to the unique thread ID
    }
}
```
- **`passenger_id`**: The bot uses this ID to **fetch user-specific flight information**.  
- **`thread_id`**: Ensures that **checkpoints** save and load data correctly for this particular conversation.  

---

### 💬 **Step 4: Running the Conversation**  
```python
_printed = set()  # Keeps track of printed events to avoid duplicates

for question in tutorial_questions:
    events = part_2_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)  # Displays the bot's response
```
- **`_printed`**: Tracks what has been displayed to prevent **repetitive output**.  
- **`part_2_graph.stream`**:  
  - Starts the chatbot's **conversation flow**.  
  - Processes each **user question** from `tutorial_questions`.  
- **`_print_event`**: Outputs each event, ensuring clarity in chatbot responses.  

---

### 🛑 **Step 5: Handling Interrupts for Confirmation**  
```python
snapshot = part_2_graph.get_state(config)  # Gets the latest state of the conversation

while snapshot.next:
    user_input = input(
        "Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changes.\n\n"
    )
```
- **`snapshot`**: Fetches the **current state** of the conversation.  
- **`while snapshot.next:`**: Checks if there is an **interrupt** (waiting for user confirmation).  
- **`input(...)`**: **Asks the user** for approval before performing sensitive actions.  

---

### ✅ **Step 6: Handling User Decision**  
#### **If user approves:**  
```python
if user_input.strip() == "y":
    result = part_2_graph.invoke(None, config)
```
- **`invoke(None, config)`**: Resumes the chatbot flow from the **saved checkpoint**.  

#### **If user denies:**  
```python
else:
    result = part_2_graph.invoke(
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
```
- **`ToolMessage(...)`**: Sends feedback to the assistant that the user **denied the action**.  
- **`content=f"API call denied by user...`**: The **reason for denial** is shared with the assistant so it can **adjust its response** accordingly.  

---

## 🌍 **Real-World Use Cases**  

### 🏦 **Banking Chatbots**  
- **Scenario**: A bot helps users transfer money.  
- **Use of Confirmation**: Before transferring, the bot asks:  
  _"Are you sure you want to transfer ₹10,000 to Alex?"_  

---

### 🏨 **Hotel Booking Assistants**  
- **Scenario**: A user tries to cancel a hotel reservation.  
- **Bot Action**:  
  _"You are about to cancel your reservation at Marriott for 15th March. Confirm?"_  

---

### 🚗 **Car Rental Services**  
- **Scenario**: A customer updates car rental details.  
- **Bot Interrupt**:  
  _"Do you want to change your pickup time from 2 PM to 5 PM? Confirm to proceed."_  

---

## 🚀 **Why This Approach is Important**  
1. ✅ **Reduces Errors**: Users don’t accidentally perform destructive actions.  
2. 🔒 **Enhances Security**: Sensitive actions require explicit user approval.  
3. 🎯 **Improves User Trust**: Users feel in control of the conversation.  

---

## 🎉 **Final Thoughts**  

By incorporating **interrupts**, **checkpoints**, and **user confirmations**, we can build intelligent and **user-friendly chatbots** that are **safe**, **reliable**, and **interactive**.  

💬 If you want more details on advanced concepts like **LangGraph flows**, **tool integrations**, or **customizing checkpoints**, feel free to ask! 😊

# Or unzasohail019@gmail.com response:

# 🚀 **Building a Chatbot with User Confirmation Using LangGraph**  

Creating a chatbot that interacts with users and takes actions on their behalf requires careful control to avoid unintended consequences. In this tutorial, we'll explore how to **interrupt** the execution of a chatbot before performing critical actions, allowing the user to confirm or modify the chatbot’s decisions.  

This is achieved using **LangGraph**, a framework for building AI workflows. We’ll also use **interrupt_before** to pause execution before calling external tools, ensuring user oversight.  

By the end of this tutorial, you’ll understand:  
✔️ How to define a **stateful chatbot** that remembers user interactions.  
✔️ How to **pause execution** before critical actions and request confirmation.  
✔️ How to build an **interactive workflow** using LangGraph.  

---  

# 🎯 **Why User Confirmation is Important?**  

When a chatbot interacts with external tools—like booking flights, updating tickets, or canceling reservations—it must ensure that:  
✔️ The **correct action** is being performed.  
✔️ The **user has control** over irreversible actions.  
✔️ **Security risks** (like prompt injections) are minimized.  

By implementing **interruptions**, we give users the power to approve or reject certain actions before they are executed.  

💡 **Real-World Example**:  
Imagine a travel assistant chatbot that helps users:  
✈️ Book flights  
🏨 Reserve hotels  
🚗 Rent cars  

Before canceling a flight or making a purchase, the chatbot **pauses** and asks:  
🔹 **"Are you sure you want to cancel your flight to Paris?"**  

This ensures that:  
✔️ The user **intended** to perform the action.  
✔️ The chatbot is **not making incorrect assumptions**.  

Now, let’s implement this concept in Python using **LangGraph**.  

---

# 🏗️ **Step 1: Define the Chatbot’s State and Assistant**  

We start by defining a **State** class to manage chatbot memory and user details. The assistant will use this state to generate responses.  

### 📌 **Code: Define State and Assistant**  

```python
from typing import Annotated
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable, RunnableConfig
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages

# 📌 Define chatbot state (memory)
class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]  # Stores past messages
    user_info: str  # Stores user details (e.g., flight info)

# 📌 Define Assistant class
class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)
            
            # ✅ If response is empty, re-prompt the AI
            if not result.tool_calls and (
                not result.content or 
                isinstance(result.content, list) and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break
        return {"messages": result}
```

### 🧐 **Explanation of the Code**  
✔️ **State Class:** Stores user messages and flight details.  
✔️ **Assistant Class:**  
   - Calls the AI to generate a response.  
   - If the response is **empty**, it **re-prompts** the AI for a valid answer.  

---

# ⚡ **Step 2: Create the Chatbot Graph with Interruptions**  

Now, we create a **LangGraph** workflow. This includes:  
✅ **Fetching user details** before responding.  
✅ **Pausing execution before performing critical actions**.  

### 📌 **Code: Define the Chatbot Graph**  

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

# ✅ Define a new LangGraph builder
builder = StateGraph(State)

# 📌 Function to fetch user flight information
def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

# ✅ Add nodes to the graph
builder.add_node("fetch_user_info", user_info)  # Fetch user details
builder.add_edge(START, "fetch_user_info")  # Start from user info node

builder.add_node("assistant", Assistant(part_2_assistant_runnable))  # AI assistant
builder.add_node("tools", create_tool_node_with_fallback(part_2_tools))  # Tools execution

# ✅ Define execution flow
builder.add_edge("fetch_user_info", "assistant")  # Fetch info → Assistant
builder.add_conditional_edges("assistant", tools_condition)  # Decide next step
builder.add_edge("tools", "assistant")  # Loop back to assistant

# ✅ Set up memory storage & interruptions
memory = MemorySaver()
part_2_graph = builder.compile(
    checkpointer=memory,  # Save state between interruptions
    interrupt_before=["tools"],  # Stop execution before using tools
)
```

### 🧐 **Explanation of the Code**  
✔️ **user_info()**: Fetches user details before chatbot interactions.  
✔️ **LangGraph Setup**:  
   - Adds an **assistant node** for responses.  
   - Adds a **tools node** for external actions.  
✔️ **Interruptions**: Execution **pauses before calling external tools**.  

---

# 🔁 **Step 3: Run the Chatbot and Handle Interruptions**  

Now, let's test the chatbot with **interactive user confirmations**.  

### 📌 **Code: Execute Chatbot with Confirmation**  

```python
import uuid

# ✅ Generate a unique session ID
thread_id = str(uuid.uuid4())

# ✅ Define chatbot config
config = {
    "configurable": {
        "passenger_id": "3442 587242",  # Fetch user flight details
        "thread_id": thread_id,  # Track conversation
    }
}

# ✅ Simulate user queries
for question in tutorial_questions:
    events = part_2_graph.stream({"messages": ("user", question)}, config, stream_mode="values")
    
    for event in events:
        _print_event(event, _printed)

    snapshot = part_2_graph.get_state(config)

    while snapshot.next:
        # ❗ User confirmation required
        user_input = input(
            "Do you approve of the above actions? Type 'y' to continue, or explain your requested change.\n"
        ).strip()

        if user_input.lower() == "y":
            result = part_2_graph.invoke(None, config)  # Continue execution
        else:
            result = part_2_graph.invoke(
                {
                    "messages": [
                        ToolMessage(
                            tool_call_id=event["messages"][-1].tool_calls[0]["id"],
                            content=f"API call denied by user. Reasoning: '{user_input}'. Continue assisting accordingly.",
                        )
                    ]
                },
                config,
            )
        
        snapshot = part_2_graph.get_state(config)
```

### 🧐 **Explanation of the Code**  
✔️ **Generates a unique session ID** for tracking.  
✔️ **Loops through user queries**, sending them to the chatbot.  
✔️ **If an action requires confirmation**, it **pauses** and asks:  
   - If **approved**, execution **continues**.  
   - If **denied**, chatbot **adjusts its response** accordingly.  

---

# 🎯 **Final Review: What We Achieved**  

✅ **Built a chatbot** that interacts with users and fetches their flight details.  
✅ **Paused execution before critical actions** (like canceling a ticket).  
✅ **Allowed users to confirm or reject actions**, improving security.  

---

# 🔥 **Next Steps**  

In the next part, we will **fine-tune the chatbot** so that only **sensitive actions** require confirmation, while less critical actions proceed automatically.  

Stay tuned! 🚀