# Part 4: Specialized Workflows¶
In the previous sections, we saw how "wide" chat-bots, relying on a single prompt and LLM to handle various user intents, can get us far. However, it's difficult to create predictably great user experiences for known intents with this approach.

Alternatively, your graph can detect userintent and select the appropriate workflow or "skill" to satisfy the user's needs. Each workflow can focus on its domain, allowing for isolated improvements without degrading the overall assistant.

In this section, we'll split user experiences into separate sub-graphs, resulting in a structure like this:



In the diagram above, each square wraps an agentic, focused workflow. The primary assistant fields the user's initial queries, and the graph routes to the appropriate "expert" based on the query content.

# State¶
We want to keep track of which sub-graph is in control at any given moment. While we could do this through some arithmetic on the message list, it's easier to track as a dedicated stack.

Add a dialog_state list to the State below. Any time a node is run and returns a value for dialog_state, the update_dialog_stack function will be called to determine how to apply the update.

```python
from typing import Annotated, Literal, Optional

from typing_extensions import TypedDict

from langgraph.graph.message import AnyMessage, add_messages


def update_dialog_stack(left: list[str], right: Optional[str]) -> list[str]:
    """Push or pop the state."""
    if right is None:
        return left
    if right == "pop":
        return left[:-1]
    return left + [right]


class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str
    dialog_state: Annotated[
        list[
            Literal[
                "assistant",
                "update_flight",
                "book_car_rental",
                "book_hotel",
                "book_excursion",
            ]
        ],
        update_dialog_stack,
    ]
API Reference: add_messages
```


# 🌟 **Part 4: Specialized Workflows**  

In this section, we’ll explore **specialized workflows** for chatbots. Instead of relying on one large language model (LLM) to handle everything, we’ll break tasks into smaller, specialized sub-graphs. Each sub-graph will focus on a specific user intent (like booking a hotel, updating a flight, etc.), making the chatbot more efficient, predictable, and user-friendly.  

---

## 📚 **Why Specialized Workflows?**  
When building complex chatbots, handling everything in a single flow is tough. For example, a travel assistant chatbot that helps with flights, hotels, cars, and excursions might struggle to manage everything at once.  

### ⚡ **Key Challenges Without Specialized Workflows:**  
1. **Complexity:** More tools and logic lead to messy code.  
2. **Reduced Accuracy:** One large LLM handling everything can make mistakes.  
3. **Difficult Improvements:** Changing one part of the workflow can affect the whole system.  

### ✅ **Benefits of Specialized Workflows:**  
1. **Modularity:** Each workflow can improve independently.  
2. **Efficiency:** Only relevant tools are used for each task.  
3. **Better Control:** Clear control over user experience for each intent.  

---

## 🌍 **Real-World Example: Travel Booking Assistant**  
Imagine a travel assistant that:  
- Updates flights  
- Books hotels  
- Reserves rental cars  
- Schedules excursions  

Each task is handled by a different specialized workflow. For example, if a user says:  
> _"I want to book a hotel for next week."_  
The chatbot identifies the intent (**book_hotel**) and routes the conversation to the hotel booking workflow, without affecting flight or car rental workflows.  

---

## 💾 **Understanding State Management**  
The **state** tracks the current status of the conversation, including:  
- Messages exchanged  
- User information  
- **Dialog state:** Which sub-graph is currently active  

We'll use a **stack** (like a pile of plates) for the `dialog_state`. This helps track which workflow is running and when to switch or return to previous ones.  

---

## 📝 **Code Breakdown with Explanations**  

### 🔧 **Step 1: Import Required Libraries**  
```python
from typing import Annotated, Literal, Optional
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages
```
- `typing`: Helps define data types for safety and clarity.  
- `TypedDict`: Defines a dictionary with specified keys and types.  
- `AnyMessage`: Represents any message in the conversation.  
- `add_messages`: Adds new messages to the conversation state.  

---

### 🔄 **Step 2: Create a Function to Manage Dialog State**  
```python
def update_dialog_stack(left: list[str], right: Optional[str]) -> list[str]:
    """Push or pop the state based on user interaction."""
    if right is None:
        return left
    if right == "pop":
        return left[:-1]  # Remove the last workflow (like popping a plate from a stack)
    return left + [right]  # Add a new workflow to the stack
```
- The **stack** tracks active workflows.  
- **Push**: Adds a new workflow when detected (e.g., `book_hotel`).  
- **Pop**: Removes a workflow when it completes.  

**🔍 Example:**  
If the user first updates a flight, then books a hotel:  
```python
["update_flight", "book_hotel"]
```
When the hotel booking finishes, we **pop**:  
```python
["update_flight"]
```

---

### 🏗️ **Step 3: Define the State Class**  
```python
class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]  # Stores conversation messages
    user_info: str  # Stores user details (e.g., passenger ID)
    dialog_state: Annotated[
        list[
            Literal[
                "assistant",
                "update_flight",
                "book_car_rental",
                "book_hotel",
                "book_excursion",
            ]
        ],
        update_dialog_stack,  # Uses the function above for stack management
    ]
```
- **messages**: History of all user and bot messages.  
- **user_info**: User-specific data (e.g., flight information).  
- **dialog_state**: Stack representing the current sub-graph in control.  

---

## 🌟 **How the Workflow Functions**  
### 🎯 **Detecting User Intent**  
The primary assistant will first process user input and then **route** to the appropriate sub-graph. For example:  
- **Intent:** “I want to update my flight.”  
  - Route to: `update_flight` workflow.  
- **Intent:** “Can you book a hotel for me?”  
  - Route to: `book_hotel` workflow.  

---

### 💬 **Example Workflow Routing**  
```python
def detect_intent(user_message: str) -> str:
    if "flight" in user_message.lower():
        return "update_flight"
    elif "hotel" in user_message.lower():
        return "book_hotel"
    elif "car" in user_message.lower():
        return "book_car_rental"
    elif "excursion" in user_message.lower():
        return "book_excursion"
    return "assistant"
```
- The **detect_intent** function scans user messages for keywords.  
- Based on the keyword, it routes the conversation to the appropriate workflow.  

---

### 🏃 **Example Run:**  
```python
# Simulating a user conversation
conversation = ["Hi! Can you book a hotel for me?"]

state = State(messages=[], user_info="Passenger_001", dialog_state=[])

for msg in conversation:
    intent = detect_intent(msg)
    state["dialog_state"] = update_dialog_stack(state["dialog_state"], intent)
    print(f"Current Workflow Stack: {state['dialog_state']}")
```

**Output:**  
```
Current Workflow Stack: ['book_hotel']
```

---

## 🎡 **Full Example: Handling Multiple User Requests**  
```python
conversation = [
    "Hi there! I want to update my flight.",
    "Now, I also need a hotel for next week.",
    "And I'd like to rent a car for 5 days.",
]

state = State(messages=[], user_info="Passenger_001", dialog_state=[])

for msg in conversation:
    intent = detect_intent(msg)
    state["dialog_state"] = update_dialog_stack(state["dialog_state"], intent)
    print(f"User said: '{msg}' ➡️ Current Workflow Stack: {state['dialog_state']}")

# Simulate completing the last workflow
state["dialog_state"] = update_dialog_stack(state["dialog_state"], "pop")
print(f"After completing a workflow: {state['dialog_state']}")
```

**Output:**  
```
User said: 'Hi there! I want to update my flight.' ➡️ Current Workflow Stack: ['update_flight']
User said: 'Now, I also need a hotel for next week.' ➡️ Current Workflow Stack: ['update_flight', 'book_hotel']
User said: 'And I'd like to rent a car for 5 days.' ➡️ Current Workflow Stack: ['update_flight', 'book_hotel', 'book_car_rental']
After completing a workflow: ['update_flight', 'book_hotel']
```

---

## 🎯 **Key Takeaways**  
- Specialized workflows improve chatbot performance by breaking down complex tasks.  
- Using a **stack** to track dialog states helps manage nested workflows.  
- The chatbot can **detect user intent** and **route** conversations dynamically.  

---

## 🏡 **Real-World Use Cases**  
1. **E-commerce Bots:** Handling product recommendations, payments, and shipping queries separately.  
2. **Healthcare Assistants:** Managing appointment bookings, prescription refills, and health information.  
3. **Banking Bots:** Processing account details, loan applications, and customer support requests.  

---

## 💡 **Conclusion**  
By splitting user interactions into **specialized sub-graphs**, we build scalable, maintainable, and user-friendly chatbots. This modular approach ensures that as the bot grows in capability, it remains predictable and efficient—leading to a superior user experience.  

---

✨ *Let me know if you need further breakdowns of each sub-graph workflow or advanced customizations!* 🌟

---

# another gpt response:
Here's a detailed explanation of **Part 4: Specialized Workflows**, structured for beginners with real-world examples, code breakdowns, and explanations of each logic component.

---

# 🚀 Part 4: Specialized Workflows in Chatbots

In previous sections, we saw how a chatbot could use a single **Large Language Model (LLM)** to process a wide range of user intents. While this approach works, it has limitations:

- It becomes hard to **predictably manage** user requests.
- As more **tools and logic** are added, maintaining **quality responses** for all intents gets complex.
- The chatbot might **struggle to prioritize** which actions to take.

To address these issues, we can **detect user intent** and route the conversation to specialized workflows or "skills." These workflows act as **expert modules**, handling specific types of user queries.

---

## 🎯 Why Use Specialized Workflows?

Instead of one assistant handling everything, we divide tasks into **focused sub-graphs**, where:

✅ **Each sub-graph handles a specific user intent**  
✅ **Tasks remain isolated**, preventing unintended interference  
✅ **New workflows can be added easily** without breaking existing ones  
✅ **Better performance** for complex workflows  

### 🏛️ Real-World Example: Travel Booking Assistant

Imagine you are building a **travel booking assistant**. Users might request:

- **Check flight details** 🛫  
- **Modify bookings** ✈️  
- **Reserve a hotel** 🏨  
- **Rent a car** 🚗  
- **Book excursions** 🎟️  

Each of these **tasks requires different logic**. Instead of one assistant trying to handle all, we can route each request to a specialized **workflow** (sub-graph).

---

## 🛠️ Implementing Specialized Workflows with Code

To create these **focused workflows**, we need a way to **track user interactions** and **route requests dynamically**.

### 🔹 Step 1: Define a `State` to Track Conversations

We need a **state object** that keeps track of:
1. **User messages** 💬
2. **User flight details** ✈️
3. **Current active workflow** (e.g., `update_flight`, `book_hotel`) 🔄

Let's define the `State` using Python's **TypedDict**:

```python
from typing import Annotated, Literal, Optional
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages

class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
    user_info: str
    dialog_state: Annotated[
        list[
            Literal[
                "assistant",          # Default assistant handling queries
                "update_flight",      # Specialized workflow for updating flights
                "book_car_rental",    # Specialized workflow for car rentals
                "book_hotel",         # Specialized workflow for hotel booking
                "book_excursion",     # Specialized workflow for excursions
            ]
        ],
        update_dialog_stack,
    ]
```

### 🔍 Explanation:
- `messages`: Stores all chat history.
- `user_info`: Stores user-specific details (e.g., flight information).
- `dialog_state`: Keeps track of which workflow is currently active.

---

### 🔹 Step 2: Manage Dialog State with `update_dialog_stack()`

We need a function to **push and pop workflow states** dynamically.

```python
def update_dialog_stack(left: list[str], right: Optional[str]) -> list[str]:
    """Push or pop the state."""
    if right is None:
        return left  # No changes
    if right == "pop":
        return left[:-1]  # Remove the last state (go back)
    return left + [right]  # Add a new state
```

### 🔍 Explanation:
- If `right` is `None`, we **keep the existing state**.
- If `right` is `"pop"`, we **remove the last active workflow** (go back).
- Otherwise, we **add a new workflow to the stack**.

🔹 **Why is this useful?**  
Imagine a user starts booking a hotel but then decides to modify their flight instead. The chatbot should **switch workflows dynamically** without losing track.

---

## 📌 How Does This Work?

### ✅ Example: Booking a Hotel
1️⃣ User: *"I want to book a hotel."*  
➡️ Assistant detects intent → **Activates `book_hotel` workflow**  
➡️ `dialog_state = ["assistant", "book_hotel"]`  

2️⃣ User: *"Actually, I need to update my flight first."*  
➡️ Assistant switches workflow → **Activates `update_flight`**  
➡️ `dialog_state = ["assistant", "update_flight"]`  

3️⃣ User: *"Never mind, back to hotel booking."*  
➡️ Assistant **pops the last state** and **resumes hotel booking**  
➡️ `dialog_state = ["assistant", "book_hotel"]`  

This **dynamic routing** makes interactions **more natural and efficient**.

---

## 🏆 Benefits of Specialized Workflows

🔹 **Better User Experience** 🎯 – More accurate responses  
🔹 **Scalability** 📈 – New workflows can be added easily  
🔹 **Maintainability** 🛠️ – Code remains modular and organized  
🔹 **Flexibility** 🔄 – Users can switch between workflows seamlessly  

---

## 🚀 What's Next?

In the next section, we will **dynamically route user queries** to these specialized workflows based on **intent detection**. Stay tuned for **building an intelligent routing system**! 🎯🚀



# Assistants¶ 
This time we will create an assistant for every workflow. That means:

- Flight booking assistant
- Hotel booking assistant
- Car rental assistant
- Excursion assistant
- and finally, a "primary assistant" to route between these

If you're paying attention, you may recognize this as an example of the supervisor design pattern from our Multi-agent examples.

Below, define the Runnable objects to power each assistant. Each Runnable has a prompt, LLM, and schemas for the tools scoped to that assistant. Each specialized / delegated assistant additionally can call the CompleteOrEscalate tool to indicate that the control flow should be passed back to the primary assistant. This happens if it has successfully completed its work or if the user has changed their mind or needs assistance on something that beyond the scope of that particular workflow.

# Using Pydantic with LangChain

This notebook uses Pydantic v2 BaseModel, which requires langchain-core >= 0.3. Using langchain-core < 0.3 will result in errors due to mixing of Pydantic v1 and v2 BaseModels.

```python
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable, RunnableConfig

from pydantic import BaseModel, Field


class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)

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


class CompleteOrEscalate(BaseModel):
    """A tool to mark the current task as completed and/or to escalate control of the dialog to the main assistant,
    who can re-route the dialog based on the user's needs."""

    cancel: bool = True
    reason: str

    class Config:
        json_schema_extra = {
            "example": {
                "cancel": True,
                "reason": "User changed their mind about the current task.",
            },
            "example 2": {
                "cancel": True,
                "reason": "I have fully completed the task.",
            },
            "example 3": {
                "cancel": False,
                "reason": "I need to search the user's emails or calendar for more information.",
            },
        }


# Flight booking assistant

flight_booking_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling flight updates. "
            " The primary assistant delegates work to you whenever the user needs help updating their bookings. "
            "Confirm the updated flight details with the customer and inform them of any additional fees. "
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\n\nCurrent user flight information:\n<Flights>\n{user_info}\n</Flights>"
            "\nCurrent time: {time}."
            "\n\nIf the user needs help, and none of your tools are appropriate for it, then"
            ' "CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.',
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

update_flight_safe_tools = [search_flights]
update_flight_sensitive_tools = [update_ticket_to_new_flight, cancel_ticket]
update_flight_tools = update_flight_safe_tools + update_flight_sensitive_tools
update_flight_runnable = flight_booking_prompt | llm.bind_tools(
    update_flight_tools + [CompleteOrEscalate]
)

# Hotel Booking Assistant
book_hotel_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling hotel bookings. "
            "The primary assistant delegates work to you whenever the user needs help booking a hotel. "
            "Search for available hotels based on the user's preferences and confirm the booking details with the customer. "
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            '\n\nIf the user needs help, and none of your tools are appropriate for it, then "CompleteOrEscalate" the dialog to the host assistant.'
            " Do not waste the user's time. Do not make up invalid tools or functions."
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'what's the weather like this time of year?'\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'i need to figure out transportation while i'm there'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Hotel booking confirmed'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

book_hotel_safe_tools = [search_hotels]
book_hotel_sensitive_tools = [book_hotel, update_hotel, cancel_hotel]
book_hotel_tools = book_hotel_safe_tools + book_hotel_sensitive_tools
book_hotel_runnable = book_hotel_prompt | llm.bind_tools(
    book_hotel_tools + [CompleteOrEscalate]
)

# Car Rental Assistant
book_car_rental_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling car rental bookings. "
            "The primary assistant delegates work to you whenever the user needs help booking a car rental. "
            "Search for available car rentals based on the user's preferences and confirm the booking details with the customer. "
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            "\n\nIf the user needs help, and none of your tools are appropriate for it, then "
            '"CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.'
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'what's the weather like this time of year?'\n"
            " - 'What flights are available?'\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Car rental booking confirmed'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

book_car_rental_safe_tools = [search_car_rentals]
book_car_rental_sensitive_tools = [
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
]
book_car_rental_tools = book_car_rental_safe_tools + book_car_rental_sensitive_tools
book_car_rental_runnable = book_car_rental_prompt | llm.bind_tools(
    book_car_rental_tools + [CompleteOrEscalate]
)

# Excursion Assistant

book_excursion_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling trip recommendations. "
            "The primary assistant delegates work to you whenever the user needs help booking a recommended trip. "
            "Search for available trip recommendations based on the user's preferences and confirm the booking details with the customer. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            '\n\nIf the user needs help, and none of your tools are appropriate for it, then "CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.'
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'i need to figure out transportation while i'm there'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Excursion booking confirmed!'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

book_excursion_safe_tools = [search_trip_recommendations]
book_excursion_sensitive_tools = [book_excursion, update_excursion, cancel_excursion]
book_excursion_tools = book_excursion_safe_tools + book_excursion_sensitive_tools
book_excursion_runnable = book_excursion_prompt | llm.bind_tools(
    book_excursion_tools + [CompleteOrEscalate]
)


# Primary Assistant
class ToFlightBookingAssistant(BaseModel):
    """Transfers work to a specialized assistant to handle flight updates and cancellations."""

    request: str = Field(
        description="Any necessary followup questions the update flight assistant should clarify before proceeding."
    )


class ToBookCarRental(BaseModel):
    """Transfers work to a specialized assistant to handle car rental bookings."""

    location: str = Field(
        description="The location where the user wants to rent a car."
    )
    start_date: str = Field(description="The start date of the car rental.")
    end_date: str = Field(description="The end date of the car rental.")
    request: str = Field(
        description="Any additional information or requests from the user regarding the car rental."
    )

    class Config:
        json_schema_extra = {
            "example": {
                "location": "Basel",
                "start_date": "2023-07-01",
                "end_date": "2023-07-05",
                "request": "I need a compact car with automatic transmission.",
            }
        }


class ToHotelBookingAssistant(BaseModel):
    """Transfer work to a specialized assistant to handle hotel bookings."""

    location: str = Field(
        description="The location where the user wants to book a hotel."
    )
    checkin_date: str = Field(description="The check-in date for the hotel.")
    checkout_date: str = Field(description="The check-out date for the hotel.")
    request: str = Field(
        description="Any additional information or requests from the user regarding the hotel booking."
    )

    class Config:
        json_schema_extra = {
            "example": {
                "location": "Zurich",
                "checkin_date": "2023-08-15",
                "checkout_date": "2023-08-20",
                "request": "I prefer a hotel near the city center with a room that has a view.",
            }
        }


class ToBookExcursion(BaseModel):
    """Transfers work to a specialized assistant to handle trip recommendation and other excursion bookings."""

    location: str = Field(
        description="The location where the user wants to book a recommended trip."
    )
    request: str = Field(
        description="Any additional information or requests from the user regarding the trip recommendation."
    )

    class Config:
        json_schema_extra = {
            "example": {
                "location": "Lucerne",
                "request": "The user is interested in outdoor activities and scenic views.",
            }
        }


# The top-level assistant performs general Q&A and delegates specialized tasks to other assistants.
# The task delegation is a simple form of semantic routing / does simple intent detection
# llm = ChatAnthropic(model="claude-3-haiku-20240307")
llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)

primary_assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            "Your primary role is to search for flight information and company policies to answer customer queries. "
            "If a customer requests to update or cancel a flight, book a car rental, book a hotel, or get trip recommendations, "
            "delegate the task to the appropriate specialized assistant by invoking the corresponding tool. You are not able to make these types of changes yourself."
            " Only the specialized assistants are given permission to do this for the user."
            "The user is not aware of the different specialized assistants, so do not mention them; just quietly delegate through function calls. "
            "Provide detailed information to the customer, and always double-check the database before concluding that information is unavailable. "
            " When searching, be persistent. Expand your query bounds if the first search returns no results. "
            " If a search comes up empty, expand your search before giving up."
            "\n\nCurrent user flight information:\n<Flights>\n{user_info}\n</Flights>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
primary_assistant_tools = [
    TavilySearchResults(max_results=1),
    search_flights,
    lookup_policy,
]
assistant_runnable = primary_assistant_prompt | llm.bind_tools(
    primary_assistant_tools
    + [
        ToFlightBookingAssistant,
        ToBookCarRental,
        ToHotelBookingAssistant,
        ToBookExcursion,
    ]
)

```

# 🤖 Creating Specialized Assistants for a Multi-Workflow Chatbot

In this section, we build on previous concepts by creating **specialized assistants** for different tasks—like flight booking, hotel booking, car rentals, and excursions—plus a **primary assistant** that acts as a supervisor. This design follows the **supervisor design pattern** (or multi-agent system), where each agent (assistant) handles a specific domain. This setup improves accuracy and user experience by ensuring that each assistant is an expert in its domain.

Let's break down the code and its purpose step-by-step.

---

## 🎯 Overview

- **Specialized Assistants:**  
  - **Flight Booking Assistant**
  - **Hotel Booking Assistant**
  - **Car Rental Assistant**
  - **Excursion Assistant**

- **Primary Assistant:**  
  Routes user requests to the appropriate specialized assistant.

- **CompleteOrEscalate Tool:**  
  A mechanism that allows any specialized assistant to **complete its task** or **escalate control** back to the primary assistant if the task is done, if the user changes their mind, or if the assistant cannot handle the query.

---

## 🛠 The `Assistant` Class

This class wraps a **Runnable** (the core processing unit) and ensures that the assistant produces a non-empty, valid response.

```python
class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable  # Store the runnable logic that powers the assistant

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)  # Invoke the runnable with the current state
            # Check if the response is valid; if not, prompt the model for a real output
            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list)
                and not result.content[0].get("text")
            ):
                # Append a re-prompt message to the conversation history
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break  # Break out if a valid response is obtained
        return {"messages": result}  # Return the final messages from the assistant
```

### 🔍 Explanation:
- **`__init__`:**  
  Stores the `runnable` object, which is the combination of a prompt, LLM, and tool bindings.

- **`__call__`:**  
  Runs the assistant logic repeatedly until a valid response is generated.  
  - **`invoke(state)`:** Calls the LLM with the current state.  
  - **Response Validation:** Checks if the output is empty or missing text, and if so, adds a message prompting for a real output.  
  - **Return:** Once a valid response is obtained, it returns the updated messages.

---

## 🔧 The `CompleteOrEscalate` Tool

This tool allows specialized assistants to either finish their task or transfer control back to the primary assistant.

```python
from pydantic import BaseModel, Field

class CompleteOrEscalate(BaseModel):
    """A tool to mark the current task as completed and/or to escalate control of the dialog to the main assistant."""
    cancel: bool = True  # Indicates whether to cancel the current task
    reason: str         # Reason for canceling or escalating

    class Config:
        json_schema_extra = {
            "example": {
                "cancel": True,
                "reason": "User changed their mind about the current task.",
            },
            "example 2": {
                "cancel": True,
                "reason": "I have fully completed the task.",
            },
            "example 3": {
                "cancel": False,
                "reason": "I need to search the user's emails or calendar for more information.",
            },
        }
```

### 🔍 Explanation:
- **`CompleteOrEscalate` Fields:**  
  - `cancel`: A flag to indicate if the current task should be terminated.  
  - `reason`: A string providing context (e.g., task completed, user changed their mind).

- **Pydantic's BaseModel:**  
  Ensures that data adheres to a specified schema, which is helpful for validation and documentation.

---

## ✈️ Flight Booking Assistant

This assistant focuses on updating flight bookings. It uses both **safe tools** (like searching flights) and **sensitive tools** (like updating or canceling flights).

```python
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

flight_booking_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling flight updates. "
            "The primary assistant delegates work to you whenever the user needs help updating their bookings. "
            "Confirm the updated flight details with the customer and inform them of any additional fees. "
            "When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\n\nCurrent user flight information:\n<Flights>\n{user_info}\n</Flights>"
            "\nCurrent time: {time}."
            "\n\nIf the user needs help, and none of your tools are appropriate for it, then"
            ' "CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.',
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 🔍 Explanation:
- **Prompt Template:**  
  Defines the system message that sets the context for flight booking.  
  - **`{user_info}`** and **`{time}`** are placeholders for dynamic data.
- **`partial(time=datetime.now)`:**  
  Pre-fills the current time so that every invocation gets a fresh timestamp.

Next, we bind the tools for flight booking:

```python
update_flight_safe_tools = [search_flights]  # Tools for read-only actions
update_flight_sensitive_tools = [update_ticket_to_new_flight, cancel_ticket]  # Tools for modifying bookings
update_flight_tools = update_flight_safe_tools + update_flight_sensitive_tools
update_flight_runnable = flight_booking_prompt | llm.bind_tools(
    update_flight_tools + [CompleteOrEscalate]
)
```

### 🔍 Explanation:
- **Tool Separation:**  
  - **Safe Tools:** For actions like searching flights.
  - **Sensitive Tools:** For actions that change bookings.
- **Binding Tools:**  
  Combines tools with the prompt using the `|` operator, effectively creating a runnable workflow.
- **`CompleteOrEscalate`:**  
  Added so the assistant can escalate control if needed.

---

## 🏨 Hotel Booking Assistant

Similarly, the hotel booking assistant is designed to handle hotel-related queries.

```python
book_hotel_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling hotel bookings. "
            "The primary assistant delegates work to you whenever the user needs help booking a hotel. "
            "Search for available hotels based on the user's preferences and confirm the booking details with the customer. "
            "When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            '\n\nIf the user needs help, and none of your tools are appropriate for it, then "CompleteOrEscalate" the dialog to the host assistant.'
            " Do not waste the user's time. Do not make up invalid tools or functions."
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'what's the weather like this time of year?'\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'i need to figure out transportation while i'm there'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Hotel booking confirmed'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 🔍 Explanation:
- **Prompt:**  
  Provides a clear instruction set specific to hotel bookings.
- **Tool Binding:**

```python
book_hotel_safe_tools = [search_hotels]
book_hotel_sensitive_tools = [book_hotel, update_hotel, cancel_hotel]
book_hotel_tools = book_hotel_safe_tools + book_hotel_sensitive_tools
book_hotel_runnable = book_hotel_prompt | llm.bind_tools(
    book_hotel_tools + [CompleteOrEscalate]
)
```

- **Safe Tools:** For searching hotels.
- **Sensitive Tools:** For booking, updating, or canceling a hotel reservation.
- **CompleteOrEscalate:** Enables escalation if the assistant cannot handle the task.

---

## 🚗 Car Rental Assistant

This assistant handles car rental bookings similarly.

```python
book_car_rental_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling car rental bookings. "
            "The primary assistant delegates work to you whenever the user needs help booking a car rental. "
            "Search for available car rentals based on the user's preferences and confirm the booking details with the customer. "
            "When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            " Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            "\n\nIf the user needs help, and none of your tools are appropriate for it, then "
            '"CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.'
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'what's the weather like this time of year?'\n"
            " - 'What flights are available?'\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Car rental booking confirmed'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

And then bind the tools:

```python
book_car_rental_safe_tools = [search_car_rentals]
book_car_rental_sensitive_tools = [
    book_car_rental,
    update_car_rental,
    cancel_car_rental,
]
book_car_rental_tools = book_car_rental_safe_tools + book_car_rental_sensitive_tools
book_car_rental_runnable = book_car_rental_prompt | llm.bind_tools(
    book_car_rental_tools + [CompleteOrEscalate]
)
```

### 🔍 Explanation:
- **Prompt & Tools:**  
  Designed specifically for car rental queries with both safe and sensitive operations.
- **`CompleteOrEscalate`:**  
  Again, added for flexibility in handling unexpected queries or user changes.

---

## 🎟️ Excursion Assistant

This assistant manages trip recommendations and excursion bookings.

```python
book_excursion_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling trip recommendations. "
            "The primary assistant delegates work to you whenever the user needs help booking a recommended trip. "
            "Search for available trip recommendations based on the user's preferences and confirm the booking details with the customer. "
            "If you need more information or the customer changes their mind, escalate the task back to the main assistant."
            "When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "Remember that a booking isn't completed until after the relevant tool has successfully been used."
            "\nCurrent time: {time}."
            '\n\nIf the user needs help, and none of your tools are appropriate for it, then "CompleteOrEscalate" the dialog to the host assistant. Do not waste the user\'s time. Do not make up invalid tools or functions.'
            "\n\nSome examples for which you should CompleteOrEscalate:\n"
            " - 'nevermind i think I'll book separately'\n"
            " - 'i need to figure out transportation while i'm there'\n"
            " - 'Oh wait i haven't booked my flight yet i'll do that first'\n"
            " - 'Excursion booking confirmed!'",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

And bind its tools:

```python
book_excursion_safe_tools = [search_trip_recommendations]
book_excursion_sensitive_tools = [book_excursion, update_excursion, cancel_excursion]
book_excursion_tools = book_excursion_safe_tools + book_excursion_sensitive_tools
book_excursion_runnable = book_excursion_prompt | llm.bind_tools(
    book_excursion_tools + [CompleteOrEscalate]
)
```

### 🔍 Explanation:
- **Prompt:**  
  Focused on handling excursions and trip recommendations.
- **Tool Separation:**  
  Again, differentiates between safe and sensitive actions.
- **CompleteOrEscalate:**  
  Provides a route back to the primary assistant if necessary.

---

## 👑 Primary Assistant

The primary assistant serves as the **frontline interface** for the user. It performs general queries and routes specialized tasks to the respective assistants.

### Specialized Data Transfer Models

Using **Pydantic**, we define models to capture user requests and transfer control to the specialized assistants.

```python
from pydantic import BaseModel, Field

class ToFlightBookingAssistant(BaseModel):
    """Transfers work to a specialized assistant to handle flight updates and cancellations."""
    request: str = Field(
        description="Any necessary followup questions the update flight assistant should clarify before proceeding."
    )

class ToBookCarRental(BaseModel):
    """Transfers work to a specialized assistant to handle car rental bookings."""
    location: str = Field(
        description="The location where the user wants to rent a car."
    )
    start_date: str = Field(description="The start date of the car rental.")
    end_date: str = Field(description="The end date of the car rental.")
    request: str = Field(
        description="Any additional information or requests from the user regarding the car rental."
    )
    class Config:
        json_schema_extra = {
            "example": {
                "location": "Basel",
                "start_date": "2023-07-01",
                "end_date": "2023-07-05",
                "request": "I need a compact car with automatic transmission.",
            }
        }

class ToHotelBookingAssistant(BaseModel):
    """Transfer work to a specialized assistant to handle hotel bookings."""
    location: str = Field(
        description="The location where the user wants to book a hotel."
    )
    checkin_date: str = Field(description="The check-in date for the hotel.")
    checkout_date: str = Field(description="The check-out date for the hotel.")
    request: str = Field(
        description="Any additional information or requests from the user regarding the hotel booking."
    )
    class Config:
        json_schema_extra = {
            "example": {
                "location": "Zurich",
                "checkin_date": "2023-08-15",
                "checkout_date": "2023-08-20",
                "request": "I prefer a hotel near the city center with a room that has a view.",
            }
        }

class ToBookExcursion(BaseModel):
    """Transfers work to a specialized assistant to handle trip recommendation and other excursion bookings."""
    location: str = Field(
        description="The location where the user wants to book a recommended trip."
    )
    request: str = Field(
        description="Any additional information or requests from the user regarding the trip recommendation."
    )
    class Config:
        json_schema_extra = {
            "example": {
                "location": "Lucerne",
                "request": "The user is interested in outdoor activities and scenic views.",
            }
        }
```

### 🔍 Explanation:
- **Pydantic Models:**  
  Define the **structure of data** to be passed from the primary assistant to the specialized assistants.  
- **Examples Provided:**  
  Offer guidance on what kind of data is expected for each task.

### Primary Assistant Runnable

Finally, we define the primary assistant's prompt and bind it with its set of tools.

```python
llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=1)

primary_assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            "Your primary role is to search for flight information and company policies to answer customer queries. "
            "If a customer requests to update or cancel a flight, book a car rental, book a hotel, or get trip recommendations, "
            "delegate the task to the appropriate specialized assistant by invoking the corresponding tool. You are not able to make these types of changes yourself."
            " Only the specialized assistants are given permission to do this for the user."
            "The user is not aware of the different specialized assistants, so do not mention them; just quietly delegate through function calls. "
            "Provide detailed information to the customer, and always double-check the database before concluding that information is unavailable. "
            "When searching, be persistent. Expand your query bounds if the first search returns no results. "
            "If a search comes up empty, expand your search before giving up."
            "\n\nCurrent user flight information:\n<Flights>\n{user_info}\n</Flights>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

primary_assistant_tools = [
    TavilySearchResults(max_results=1),
    search_flights,
    lookup_policy,
]
assistant_runnable = primary_assistant_prompt | llm.bind_tools(
    primary_assistant_tools
    + [
        ToFlightBookingAssistant,
        ToBookCarRental,
        ToHotelBookingAssistant,
        ToBookExcursion,
    ]
)
```

### 🔍 Explanation:
- **Primary Assistant Prompt:**  
  Guides the primary assistant to handle general queries and **delegate specialized tasks**.  
- **Tool Binding:**  
  Combines tools for flight searches and policy lookups with the Pydantic models that enable task delegation.
- **`assistant_runnable`:**  
  The complete runnable logic for the primary assistant.

---

## 🌟 Real-World Use Case Recap

Imagine a customer of Swiss Airlines interacting with a virtual assistant:
- They ask about their flight details, and the **primary assistant** responds with information.
- When the customer wants to update their flight, the **primary assistant** delegates the request to the **Flight Booking Assistant**.
- If the customer decides to book a hotel or car rental, the respective specialized assistants take over, ensuring that each domain is handled by an expert.

This multi-agent architecture leads to:
- **More accurate and context-specific responses**
- **Increased user trust** because actions are confirmed by domain experts
- **Easier maintenance and scalability** since each assistant can be updated independently

---

## 🎯 Conclusion

By structuring your chatbot into **specialized assistants** with a **primary assistant** handling routing, you create a **scalable**, **modular**, and **efficient** system. This approach:
- **Isolates complex logic** into focused sub-graphs (or workflows).
- **Empowers each assistant** to handle domain-specific tasks more effectively.
- **Improves user experience** by ensuring that the right assistant handles the right task.

This design pattern, akin to a **supervisor system in multi-agent architectures**, is ideal for complex applications like travel booking, customer support, and any domain requiring specialized handling of diverse tasks.

# Another Response:
# ✈️ **Multi-Assistant Travel Booking System with LangChain and Pydantic**  

In this guide, we'll break down a **multi-assistant travel booking system** step by step, ensuring beginners can easily follow along. We'll build assistants to handle:  

- ✈️ **Flight Booking**  
- 🏨 **Hotel Booking**  
- 🚗 **Car Rental**  
- 🏔️ **Excursions**  
- 🌐 **Primary Assistant** (routes between all other assistants)  

We’ll use **LangChain**, **Pydantic**, and **Python** concepts. Each section includes:  
✅ **Detailed explanations**  
📝 **Code examples**  
💡 **Line-by-line explanations**  

---

## 🌟 **Why a Multi-Assistant System?**  
This system follows the **Supervisor Design Pattern**—one main assistant delegates tasks to specialized assistants, improving modularity, scalability, and error handling.  

---

## ⚙️ **Step 1: Setting Up the Project**  

### 🚀 **Install Required Libraries**  
```bash
pip install langchain langchain-anthropic langchain-community pydantic
```
- `langchain`: Framework for building LLM-powered applications.  
- `langchain-anthropic`: Anthropic language model integration.  
- `pydantic`: Data validation and parsing using Python type annotations.  

---

## 🎛️ **Step 2: Creating the Assistant Class**  

This class acts as a wrapper to run each assistant’s workflow.

### 📝 **Code Example: `Assistant` Class**  
```python
from langchain_core.runnables import Runnable, RunnableConfig

class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable  # Each assistant will have a runnable workflow

    def __call__(self, state, config: RunnableConfig):
        while True:
            result = self.runnable.invoke(state)  # Execute the assistant's workflow
            if not result.tool_calls and (not result.content or (isinstance(result.content, list) and not result.content[0].get("text"))):
                state["messages"].append(("user", "Respond with a real output."))
            else:
                break
        return {"messages": result}
```

### 🔍 **Line-by-Line Explanation**  
- **`__init__`**: Takes a `Runnable` (workflow) and assigns it to the assistant.  
- **`__call__`**: Repeatedly runs the assistant until it returns a meaningful response.  
- **Error Handling**: If no valid response is generated, it prompts the assistant to try again.  

---

## 🛠️ **Step 3: Implementing `CompleteOrEscalate` Tool**  

This tool allows specialized assistants to:  
1️⃣ Mark a task as complete.  
2️⃣ Escalate the task back to the **Primary Assistant** if more information is needed.  

### 📝 **Code Example: `CompleteOrEscalate` Tool**  
```python
from pydantic import BaseModel, Field

class CompleteOrEscalate(BaseModel):
    cancel: bool = True  # True if the assistant should stop the task
    reason: str          # Reason for completing or escalating

    class Config:
        json_schema_extra = {
            "example": {
                "cancel": True,
                "reason": "User changed their mind about the current task."
            }
        }
```

### 🔍 **Explanation**  
- **`cancel`**: If `True`, the assistant stops its task.  
- **`reason`**: Explains why the task was stopped or escalated.  
- **`json_schema_extra`**: Provides examples for documentation and testing.  

---

## ✈️ **Step 4: Flight Booking Assistant**  

Handles flight updates, confirmations, and cancellations.

### 📝 **Flight Booking Prompt**  
```python
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

flight_booking_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a specialized assistant for handling flight updates. Confirm flight details, inform about fees, "
            "and escalate tasks if needed.\n\nCurrent user flight information:\n<Flights>\n{user_info}\n</Flights>"
            "\nCurrent time: {time}."
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 🔍 **Explanation**  
- **Prompt**: Instructs the assistant to confirm flight details, handle updates, and escalate if needed.  
- **`partial(time=datetime.now)`**: Inserts the current time dynamically into the prompt.  

### 📝 **Combining Prompt with Tools**  
```python
update_flight_tools = [search_flights, update_ticket_to_new_flight, cancel_ticket, CompleteOrEscalate]
update_flight_runnable = flight_booking_prompt | llm.bind_tools(update_flight_tools)
```

### 💡 **Key Concept**:  
- **`|` Operator**: Combines the prompt with the specified tools (pipeline operator).  
- **`bind_tools()`**: Connects relevant tools to the assistant, enabling them to perform actions like searching or canceling flights.  

---

## 🏨 **Step 5: Hotel Booking Assistant**  

Handles hotel searches, bookings, updates, and cancellations.

### 📝 **Hotel Booking Prompt**  
```python
book_hotel_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a hotel booking assistant. Search for hotels based on user preferences and confirm bookings. "
            "Escalate if user changes their mind or if additional information is required.\n\nCurrent time: {time}."
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 📝 **Combining Prompt with Tools**  
```python
book_hotel_tools = [search_hotels, book_hotel, update_hotel, cancel_hotel, CompleteOrEscalate]
book_hotel_runnable = book_hotel_prompt | llm.bind_tools(book_hotel_tools)
```

---

## 🚗 **Step 6: Car Rental Assistant**  

Handles car rental processes with similar logic.  

```python
book_car_rental_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a car rental assistant. Find rental options based on user preferences and confirm details. "
            "Escalate to the main assistant if required.\n\nCurrent time: {time}."
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

book_car_rental_tools = [search_car_rentals, book_car_rental, update_car_rental, cancel_car_rental, CompleteOrEscalate]
book_car_rental_runnable = book_car_rental_prompt | llm.bind_tools(book_car_rental_tools)
```

---

## 🏔️ **Step 7: Excursion Assistant**  

```python
book_excursion_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an excursion assistant. Suggest and book trips based on user interests. "
            "Escalate to the primary assistant if bookings can’t be confirmed.\n\nCurrent time: {time}."
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)

book_excursion_tools = [search_trip_recommendations, book_excursion, update_excursion, cancel_excursion, CompleteOrEscalate]
book_excursion_runnable = book_excursion_prompt | llm.bind_tools(book_excursion_tools)
```

---

## 🌐 **Step 8: Primary Assistant**  

The **Primary Assistant** routes tasks to the specialized assistants based on user requests.

### 📝 **Primary Assistant Prompt**  
```python
primary_assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are the primary assistant for Swiss Airlines. Delegate tasks like flight updates, hotel bookings, "
            "car rentals, and excursions to specialized assistants. Escalate when appropriate."
        ),
        ("placeholder", "{messages}"),
    ]
)
```

### 📝 **Combining with Specialized Assistants**  
```python
primary_assistant_runnable = primary_assistant_prompt | llm.bind_tools(
    [ToFlightBookingAssistant, ToBookCarRental, ToHotelBookingAssistant, ToBookExcursion]
)
```

---

## 🎬 **Step 9: Running the Full Workflow**  

### 🏃 **Run the Primary Assistant**  
```python
state = {"messages": [("user", "I want to book a flight from Zurich to Paris next Monday.")]}
primary_assistant = Assistant(primary_assistant_runnable)
result = primary_assistant(state, RunnableConfig())
print(result)
```

---

## 🎉 **Congratulations!** 🎉  
You now have a fully functional **multi-assistant travel booking system** that:  
✅ Handles complex tasks with specialized assistants  
✅ Uses **LangChain** pipelines efficiently  
✅ Applies **Pydantic** for robust data validation  
✅ Escalates tasks when necessary via a **Primary Assistant**  

💬 **Got any questions?** Let me know! 😊

# Create Assistant¶
We're about ready to create the graph. In the previous section, we made the design decision to have a shared messages state between all the nodes. This is powerful in that each delegated assistant can see the entire user journey and have a shared context. This, however, means that weaker LLMs can easily get mixed up about there specific scope. To mark the "handoff" between the primary assistant and one of the delegated workflows (and complete the tool call from the router), we will add a ToolMessage to the state.

# Utility¶
Create a function to make an "entry" node for each workflow, stating "the current assistant is assistant_name".

```python
from typing import Callable

from langchain_core.messages import ToolMessage


def create_entry_node(assistant_name: str, new_dialog_state: str) -> Callable:
    def entry_node(state: State) -> dict:
        tool_call_id = state["messages"][-1].tool_calls[0]["id"]
        return {
            "messages": [
                ToolMessage(
                    content=f"The assistant is now the {assistant_name}. Reflect on the above conversation between the host assistant and the user."
                    f" The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are {assistant_name},"
                    " and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool."
                    " If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control."
                    " Do not mention who you are - just act as the proxy for the assistant.",
                    tool_call_id=tool_call_id,
                )
            ],
            "dialog_state": new_dialog_state,
        }

    return entry_node
API Reference: ToolMessage
```
# Define Graph¶
Now it's time to start building our graph. As before, we'll start with a node to pre-populate the state with the user's current information.

```python
from typing import Literal

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

builder = StateGraph(State)


def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}


builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")
API Reference: MemorySaver | StateGraph | tools_condition

```

# 🌟 **Understanding Graph Creation in Conversational AI Systems**  

In this explanation, we'll break down the concept of **graph creation** in conversational AI using **LangGraph**, specifically focusing on how multiple assistants (or workflows) collaborate while sharing a unified state. We'll cover:  
- What graphs mean in this context.  
- Why sharing state is powerful but tricky.  
- How to create entry nodes for different assistants.  
- How to define the graph to handle user information and tool messages.  
- Real-world examples of where this concept is used.  

We'll break it all down step by step, with simple explanations and examples. Let’s get started! 🚀  

---

## 🔗 **What Is a Graph in Conversational AI?**  

In conversational AI systems, a **graph** represents the **flow of conversation** between the user and the AI, showing how the AI processes requests step by step.  
- Each **node** in the graph represents a particular action or assistant.  
- The **edges** represent the flow from one action to another.  

### ✅ **Example:**  
Imagine you’re chatting with an airline's virtual assistant to:  
1. Check flight details.  
2. Update your booking.  
3. Request a refund.  

Each task would be handled by a different **assistant**, but they need to **share information** about your journey. The graph ensures that when you switch from one task to another, the conversation **flows smoothly** without repeating information.  

---

## 💡 **Why Share a Common Messages State?**  

The design choice made here is to have a **shared messages state** between all the assistants.  

### 🎯 **What Does This Mean?**  
All the assistants can see the **entire conversation history**, so when you switch from one assistant to another, the new assistant knows:  
- What you already asked.  
- Which tasks are incomplete.  
- The current context of the conversation.  

### ⚡ **Why Is This Powerful?**  
- **Seamless Experience:** The user doesn't have to repeat themselves.  
- **Context-Aware Responses:** Each assistant knows where the conversation left off.  

### ⚠️ **The Challenge:**  
Weaker AI models (**LLMs**) might get **confused** because they see **everything** and might forget their **specific role**.  

### 🔄 **Solution:**  
We introduce a **ToolMessage** to **clearly indicate** when one assistant hands over the conversation to another.  

---

## 🛠️ **Creating an Entry Node for Each Assistant**  

To avoid confusion between different assistants, we create an **entry node**.  
- An **entry node** marks when the **primary assistant** hands over the task to a **specific assistant**.  
- It ensures the new assistant knows its **exact responsibility** in the conversation.  

### 💻 **Code Explanation:**  

```python
from typing import Callable
from langchain_core.messages import ToolMessage

def create_entry_node(assistant_name: str, new_dialog_state: str) -> Callable:
    def entry_node(state: State) -> dict:
        tool_call_id = state["messages"][-1].tool_calls[0]["id"]
        return {
            "messages": [
                ToolMessage(
                    content=f"The assistant is now the {assistant_name}. Reflect on the above conversation between the host assistant and the user."
                    f" The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are {assistant_name},"
                    " and the booking, update, or other action is not complete until after you have successfully invoked the appropriate tool."
                    " If the user changes their mind, call the CompleteOrEscalate function to let the primary host assistant take control."
                    " Do not mention who you are - just act as the proxy for the assistant.",
                    tool_call_id=tool_call_id,
                )
            ],
            "dialog_state": new_dialog_state,
        }

    return entry_node
```

---

### 📝 **Beginner-Friendly Explanation:**  
- **Function Purpose:** Creates a **node** (step) in the graph for each **assistant** when it takes over.  
- **`assistant_name`:** The name of the assistant (e.g., *FlightBookingAssistant*).  
- **`new_dialog_state`:** The updated state after the assistant takes over.  
- **`ToolMessage`:** A message saying, “Hey, this assistant is now in charge!” It **does not tell the user** who the assistant is — it just **acts** on the user’s request.  

### 🎯 **Example:**  
You ask: *"I want to update my flight date."*  
- The **primary assistant** checks the request.  
- It realizes this is a **flight update task**, so it **hands over** to the **FlightUpdateAssistant** by calling this **entry node**, which gives the update assistant **full context** of the conversation.  

---

## 🌐 **Defining the Graph**  

Now that we have entry nodes for each assistant, we need to **build the entire conversation graph**.  
- The graph will show how the conversation **flows** from start to finish.  
- We will begin by **pre-populating** user information.  

### 💻 **Code Explanation:**

```python
from typing import Literal
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

builder = StateGraph(State)

def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

builder.add_node("fetch_user_info", user_info)
builder.add_edge(START, "fetch_user_info")
```

---

### 📝 **Beginner-Friendly Explanation:**  
- **`StateGraph`:** Creates a **graph** for conversation flow.  
- **`user_info` Function:**  
   - **Purpose:** Fetches the **user’s flight information** (like booking details, seat number, etc.).  
   - **Why?:** So any assistant working on a task **already knows** the user’s flight details.  
- **`add_node`:** Adds a **step** in the graph where **user information** is fetched.  
- **`add_edge`:** Connects the **start** of the conversation to this **fetch user info step**.  

### ✈️ **Real-World Example:**  
In an airline chatbot:  
- The **first step** is always to **fetch your flight information** after you say "Hi".  
- This way, no matter what you ask next—**changing flights**, **booking meals**, or **requesting upgrades**—the assistant **already knows** your details.  

---

## 🌟 **Real-World Use Case: Airline Virtual Assistant**  

Imagine you are chatting with an airline's assistant:  
1. You say: *"I want to reschedule my flight."*  
2. The assistant checks your current flight details (**fetch_user_info node**).  
3. The **primary assistant** passes the task to the **FlightUpdateAssistant** (**entry node created using `create_entry_node`**).  
4. The **FlightUpdateAssistant** reschedules your flight and confirms the update.  
5. If you suddenly say: *"Actually, I want a refund instead,"* the assistant calls the **CompleteOrEscalate function** to let the **primary assistant** take control and pass the task to the **RefundAssistant**.  

### 🎯 **Why This Matters:**  
This graph ensures:  
- ✅ No repeated questions.  
- ✅ Assistants know **exactly** what the user wants.  
- ✅ Smooth handoffs between multiple assistants.  

---

## 🎁 **Key Takeaways**  
1. **Graph in Conversational AI**: Shows the flow of conversation between user and assistants.  
2. **Shared State**: All assistants share conversation history for seamless experiences.  
3. **Entry Node**: Marks handover between assistants so each assistant knows its role.  
4. **ToolMessage**: A special message signaling an assistant switch without confusing the user.  
5. **Graph Definition**: Shows how conversations progress step by step, fetching user info first.  

---

## 🎉 **Conclusion**  
By structuring conversations as a **graph** and using techniques like **ToolMessage** and **entry nodes**, we create powerful AI assistants capable of handling complex user journeys without losing context.  

This approach is used in:  
- ✈️ **Airline booking assistants**  
- 🏨 **Hotel reservation systems**  
- 🛒 **E-commerce chatbots**  
- 💳 **Banking virtual assistants**  

All these applications require **smooth handoffs** between various tasks while keeping the **user experience simple and intuitive**. 🌟

# Another gpt Response:
# 🤖 Creating a Shared Assistant Graph with Clear Handoffs

In this section, we learn how to create a **graph-based workflow** for a multi-agent chatbot. This approach uses a **shared messages state** so that every delegated assistant (or sub-agent) can see the entire conversation history. However, sharing all context can sometimes confuse weaker language models, especially when switching tasks. To prevent this, we insert a **"handoff" message** (a ToolMessage) into the state that clearly indicates which specialized assistant should take over.

This technique is especially useful in systems like travel booking assistants, where a **primary assistant** handles general queries, and specialized assistants (flight booking, hotel booking, etc.) take over when needed.

---

## 📌 Key Concepts

### 1️⃣ **Shared Messages State**  
- **What it is:** A state that holds the complete conversation history.
- **Why it's useful:**  
  - Every assistant sees the full dialogue context.
  - It helps maintain continuity between different workflows.

### 2️⃣ **Handoff with ToolMessage**  
- **What it is:** A message inserted into the state that signals the transition from the primary assistant to a specialized assistant.
- **Why it's important:**  
  - It prevents confusion by clearly marking the start of a new, focused workflow.
  - It tells the new assistant, _"You are now in charge, and here's the context so far."_ 

### 3️⃣ **Entry Node Function**  
- **Purpose:**  
  - Acts as the first step in each specialized workflow.
  - Updates the dialogue state and adds a message indicating which assistant is now active.
  
---

## 🔧 Code Walkthrough

Let's break down the code step by step.

### 📝 **Utility Function: `create_entry_node`**

This function creates an **entry node** for a specialized assistant. It injects a `ToolMessage` into the shared state to mark the handoff.

```python
from typing import Callable
from langchain_core.messages import ToolMessage

def create_entry_node(assistant_name: str, new_dialog_state: str) -> Callable:
    def entry_node(state: State) -> dict:
        # Retrieve the ID of the latest tool call from the last message in the state.
        tool_call_id = state["messages"][-1].tool_calls[0]["id"]
        # Create a new ToolMessage that indicates a handoff to a specialized assistant.
        return {
            "messages": [
                ToolMessage(
                    content=f"The assistant is now the {assistant_name}. Reflect on the above conversation between the host assistant and the user."
                            f" The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are {assistant_name},"
                            " and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool."
                            " If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control."
                            " Do not mention who you are - just act as the proxy for the assistant.",
                    tool_call_id=tool_call_id,  # Link the message to the existing tool call.
                )
            ],
            "dialog_state": new_dialog_state,  # Update the dialogue state to the new specialized workflow.
        }
    return entry_node
```

#### 🔍 **Explanation:**

- **Function Signature:**  
  `create_entry_node(assistant_name: str, new_dialog_state: str)` returns a callable function.
  
- **Inside `entry_node`:**  
  - **Retrieve `tool_call_id`:**  
    - Accesses the most recent tool call ID from the shared state. This ties the handoff to the current conversation.
  - **Create `ToolMessage`:**  
    - The message content clearly informs that the active assistant is now `assistant_name`.
    - It instructs the new assistant to use its own tools to complete the task and to escalate back if needed.
  - **Update `dialog_state`:**  
    - Sets the new dialogue state so the system knows which specialized workflow is active.
    
- **Return:**  
  - The function returns a dictionary with updated messages and dialogue state.

---

## 🌐 **Defining the Graph**

After creating our entry node, we start building the overall conversation graph.

```python
from typing import Literal
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import StateGraph
from langgraph.prebuilt import tools_condition

# Initialize the graph with the shared State type.
builder = StateGraph(State)

# Define a function to fetch user flight information.
def user_info(state: State):
    return {"user_info": fetch_user_flight_information.invoke({})}

# Add the node to fetch user info.
builder.add_node("fetch_user_info", user_info)
# Connect the start of the conversation to the user info node.
builder.add_edge(START, "fetch_user_info")
```

#### 🔍 **Explanation:**

- **`StateGraph(State)`:**  
  - Initializes a graph that uses our shared `State` structure.
  
- **User Information Node (`user_info`):**  
  - This function populates the state with current flight information by calling `fetch_user_flight_information.invoke({})`.
  - It ensures the assistant has up-to-date context before any further processing.

- **Adding Nodes and Edges:**
  - `builder.add_node("fetch_user_info", user_info)`  
    - Adds a node named `"fetch_user_info"` to the graph.
  - `builder.add_edge(START, "fetch_user_info")`  
    - Connects the start of the graph to the `"fetch_user_info"` node, ensuring that the conversation begins by gathering necessary user data.

---

## 🏛️ **Real-World Example**

Imagine you are using a **travel booking assistant**:
- **Scenario:**  
  - You start a conversation with the primary assistant.
  - The assistant fetches your flight details (using the `user_info` node).
  - When you request to update your booking, the system inserts a handoff message using `create_entry_node`, which clearly signals, "The assistant is now the Flight Booking Assistant."
  - This ensures that the flight booking assistant receives the complete conversation context and knows it is now in charge of updating your flight booking.

This mechanism prevents confusion by:
- **Marking clear transitions** between different assistants.
- Allowing each specialized assistant to focus solely on its domain without interference from unrelated parts of the conversation.

---

## 🎯 **Summary**

- **Shared State:**  
  - Keeps the full conversation context accessible to all assistants.
  
- **Handoff via ToolMessage:**  
  - Injects a clear marker into the conversation when switching from the primary assistant to a specialized one.
  
- **Graph Definition:**  
  - Sets up the conversation flow starting with user information retrieval.
  
- **Real-World Application:**  
  - Ensures seamless transitions in a travel booking system where different tasks (flight booking, hotel booking, etc.) are handled by domain-specific assistants.

By using this approach, we create a robust, modular, and clear workflow that enhances both the efficiency of the assistant and the user experience.



**Now we'll start adding our specialized workflows. Each mini-workflow looks very similar to our full graph in Part 3, employing 5 nodes:**

enter_*: use the create_entry_node utility you defined above to add a ToolMessage signaling that the new specialized assistant is at the helm
Assistant: the prompt + llm combo that takes in the current state and either uses a tool, asks a question of the user, or ends the workflow (return to the primary assistant)
*_safe_tools: "read-only" tools the assistant can use without user confirmation.
*_sensitive_tools: tools with "write" access that require user confirmation (and will be assigned an interrupt_before when we compile the graph)
leave_skill: pop the dialog_state to signal that the primary assistant is back in control
Because of their similarities, we could define a factory function to generate these. Since this is a tutorial, we'll define them each explicitly.



# First, make the flight booking assistant dedicated to managing the user journey for updating and canceling flights. 


# Flight booking assistant
```python
builder.add_node(
    "enter_update_flight",
    create_entry_node("Flight Updates & Booking Assistant", "update_flight"),
)
builder.add_node("update_flight", Assistant(update_flight_runnable))
builder.add_edge("enter_update_flight", "update_flight")
builder.add_node(
    "update_flight_sensitive_tools",
    create_tool_node_with_fallback(update_flight_sensitive_tools),
)
builder.add_node(
    "update_flight_safe_tools",
    create_tool_node_with_fallback(update_flight_safe_tools),
)


def route_update_flight(
    state: State,
):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in update_flight_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "update_flight_safe_tools"
    return "update_flight_sensitive_tools"


builder.add_edge("update_flight_sensitive_tools", "update_flight")
builder.add_edge("update_flight_safe_tools", "update_flight")
builder.add_conditional_edges(
    "update_flight",
    route_update_flight,
    ["update_flight_sensitive_tools", "update_flight_safe_tools", "leave_skill", END],
)


# This node will be shared for exiting all specialized assistants
def pop_dialog_state(state: State) -> dict:
    """Pop the dialog stack and return to the main assistant.

    This lets the full graph explicitly track the dialog flow and delegate control
    to specific sub-graphs.
    """
    messages = []
    if state["messages"][-1].tool_calls:
        # Note: Doesn't currently handle the edge case where the llm performs parallel tool calls
        messages.append(
            ToolMessage(
                content="Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.",
                tool_call_id=state["messages"][-1].tool_calls[0]["id"],
            )
        )
    return {
        "dialog_state": "pop",
        "messages": messages,
    }


builder.add_node("leave_skill", pop_dialog_state)
builder.add_edge("leave_skill", "primary_assistant")
```

# Next, create the car rental assistant graph to own all car rental needs. 

# Car rental assistant
```python
builder.add_node(
    "enter_book_car_rental",
    create_entry_node("Car Rental Assistant", "book_car_rental"),
)
builder.add_node("book_car_rental", Assistant(book_car_rental_runnable))
builder.add_edge("enter_book_car_rental", "book_car_rental")
builder.add_node(
    "book_car_rental_safe_tools",
    create_tool_node_with_fallback(book_car_rental_safe_tools),
)
builder.add_node(
    "book_car_rental_sensitive_tools",
    create_tool_node_with_fallback(book_car_rental_sensitive_tools),
)


def route_book_car_rental(
    state: State,
):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in book_car_rental_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "book_car_rental_safe_tools"
    return "book_car_rental_sensitive_tools"


builder.add_edge("book_car_rental_sensitive_tools", "book_car_rental")
builder.add_edge("book_car_rental_safe_tools", "book_car_rental")
builder.add_conditional_edges(
    "book_car_rental",
    route_book_car_rental,
    [
        "book_car_rental_safe_tools",
        "book_car_rental_sensitive_tools",
        "leave_skill",
        END,
    ],
)

```

# Then define the hotel booking workflow. 

# Hotel booking assistant
```python
builder.add_node(
    "enter_book_hotel", create_entry_node("Hotel Booking Assistant", "book_hotel")
)
builder.add_node("book_hotel", Assistant(book_hotel_runnable))
builder.add_edge("enter_book_hotel", "book_hotel")
builder.add_node(
    "book_hotel_safe_tools",
    create_tool_node_with_fallback(book_hotel_safe_tools),
)
builder.add_node(
    "book_hotel_sensitive_tools",
    create_tool_node_with_fallback(book_hotel_sensitive_tools),
)


def route_book_hotel(
    state: State,
):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    tool_names = [t.name for t in book_hotel_safe_tools]
    if all(tc["name"] in tool_names for tc in tool_calls):
        return "book_hotel_safe_tools"
    return "book_hotel_sensitive_tools"


builder.add_edge("book_hotel_sensitive_tools", "book_hotel")
builder.add_edge("book_hotel_safe_tools", "book_hotel")
builder.add_conditional_edges(
    "book_hotel",
    route_book_hotel,
    ["leave_skill", "book_hotel_safe_tools", "book_hotel_sensitive_tools", END],
)
```

# After that, define the excursion assistant. 

# Excursion assistant
```python
builder.add_node(
    "enter_book_excursion",
    create_entry_node("Trip Recommendation Assistant", "book_excursion"),
)
builder.add_node("book_excursion", Assistant(book_excursion_runnable))
builder.add_edge("enter_book_excursion", "book_excursion")
builder.add_node(
    "book_excursion_safe_tools",
    create_tool_node_with_fallback(book_excursion_safe_tools),
)
builder.add_node(
    "book_excursion_sensitive_tools",
    create_tool_node_with_fallback(book_excursion_sensitive_tools),
)


def route_book_excursion(
    state: State,
):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    tool_names = [t.name for t in book_excursion_safe_tools]
    if all(tc["name"] in tool_names for tc in tool_calls):
        return "book_excursion_safe_tools"
    return "book_excursion_sensitive_tools"


builder.add_edge("book_excursion_sensitive_tools", "book_excursion")
builder.add_edge("book_excursion_safe_tools", "book_excursion")
builder.add_conditional_edges(
    "book_excursion",
    route_book_excursion,
    ["book_excursion_safe_tools", "book_excursion_sensitive_tools", "leave_skill", END],
)

```
# Finally, create the primary assistant. 

# Primary assistant

```python
builder.add_node("primary_assistant", Assistant(assistant_runnable))
builder.add_node(
    "primary_assistant_tools", create_tool_node_with_fallback(primary_assistant_tools)
)


def route_primary_assistant(
    state: State,
):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    if tool_calls:
        if tool_calls[0]["name"] == ToFlightBookingAssistant.__name__:
            return "enter_update_flight"
        elif tool_calls[0]["name"] == ToBookCarRental.__name__:
            return "enter_book_car_rental"
        elif tool_calls[0]["name"] == ToHotelBookingAssistant.__name__:
            return "enter_book_hotel"
        elif tool_calls[0]["name"] == ToBookExcursion.__name__:
            return "enter_book_excursion"
        return "primary_assistant_tools"
    raise ValueError("Invalid route")

```
# The assistant can route to one of the delegated assistants,
# directly use a tool, or directly respond to the user
```python
builder.add_conditional_edges(
    "primary_assistant",
    route_primary_assistant,
    [
        "enter_update_flight",
        "enter_book_car_rental",
        "enter_book_hotel",
        "enter_book_excursion",
        "primary_assistant_tools",
        END,
    ],
)
builder.add_edge("primary_assistant_tools", "primary_assistant")
```

# Each delegated workflow can directly respond to the user
# When the user responds, we want to return to the currently active workflow
```python
def route_to_workflow(
    state: State,
) -> Literal[
    "primary_assistant",
    "update_flight",
    "book_car_rental",
    "book_hotel",
    "book_excursion",
]:
    """If we are in a delegated state, route directly to the appropriate assistant."""
    dialog_state = state.get("dialog_state")
    if not dialog_state:
        return "primary_assistant"
    return dialog_state[-1]


builder.add_conditional_edges("fetch_user_info", route_to_workflow)
```
# Compile graph
```python
memory = MemorySaver()
part_4_graph = builder.compile(
    checkpointer=memory,
    # Let the user approve or deny the use of sensitive tools
    interrupt_before=[
        "update_flight_sensitive_tools",
        "book_car_rental_sensitive_tools",
        "book_hotel_sensitive_tools",
        "book_excursion_sensitive_tools",
    ],
)
```


# 🚀 Building Specialized Workflows in a Multi-Agent Chatbot

In this section, we set up **specialized workflows** for different tasks (e.g., flight booking, car rental, hotel booking, excursion recommendations) in a multi-agent chatbot. Each workflow is represented as a sub-graph with five key nodes:

1. **enter_*** – A node that uses our `create_entry_node` utility to mark the handoff to a specialized assistant.  
2. **Assistant** – The node that contains the assistant's prompt and LLM logic to process the conversation (using its dedicated runnable).  
3. **\*_safe_tools** – A node for "read-only" tools that the assistant can call without user confirmation.  
4. **\*_sensitive_tools** – A node for tools that modify data ("write" actions) which require user confirmation (and are interrupted before execution).  
5. **leave_skill** – A node that “pops” the dialog state to signal that the specialized workflow is finished and control should return to the primary assistant.

This design pattern is similar to the **supervisor design pattern** in multi-agent systems. Let’s walk through the code step-by-step with explanations and real-world examples.

---

## 🔑 Key Concepts

- **Specialized Workflows:**  
  Divide the overall conversation into separate domains (flight, car, hotel, excursion) to provide focused and expert responses.

- **Handoff with ToolMessage:**  
  Use a special message (ToolMessage) to signal the switch of control from the primary assistant to a specialized assistant.

- **Routing Logic:**  
  Conditional edges determine which node to execute next, based on the tool calls made by the assistant.

- **Dialog State:**  
  A shared state that tracks the current workflow, ensuring a smooth handoff and eventual return to the primary assistant.

---

## ✨ Real-World Example

Imagine you’re using a travel assistant:
- You start by asking about your flight.
- Later, you decide to change your flight (handled by the **Flight Booking Assistant**).
- Then, you ask for a car rental, so control passes to the **Car Rental Assistant**.
- When you’re done with a specialized task, control returns to the primary assistant to answer general queries.
  
This ensures that each task is managed by an expert module, improving clarity and reliability.

---

## 🔧 Code Walkthrough

Below is the detailed explanation of the code that sets up these specialized workflows.

---

### 1️⃣ Flight Booking Assistant Workflow

#### **Creating the Entry Node**

```python
# Flight booking assistant entry node: marks handoff to Flight Booking Assistant.
builder.add_node(
    "enter_update_flight",
    create_entry_node("Flight Updates & Booking Assistant", "update_flight"),
)
```

- **Purpose:**  
  - The `create_entry_node` function creates a node that sends a ToolMessage indicating that control is handed over to the **Flight Updates & Booking Assistant**.  
  - It also updates the dialog state to `"update_flight"`.

#### **Setting Up the Flight Booking Assistant Node**

```python
builder.add_node("update_flight", Assistant(update_flight_runnable))
builder.add_edge("enter_update_flight", "update_flight")
```

- **Assistant Node:**  
  - Uses the `Assistant` class wrapped around `update_flight_runnable` (the flight booking logic).
  - An edge is added to connect the entry node to the flight booking assistant.

#### **Defining Tools for Flight Booking**

```python
builder.add_node(
    "update_flight_sensitive_tools",
    create_tool_node_with_fallback(update_flight_sensitive_tools),
)
builder.add_node(
    "update_flight_safe_tools",
    create_tool_node_with_fallback(update_flight_safe_tools),
)
```

- **Safe Tools:**  
  - Tools that search flights (read-only actions).
- **Sensitive Tools:**  
  - Tools that update or cancel flights (write actions requiring confirmation).

#### **Routing Logic for Flight Booking**

```python
def route_update_flight(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in update_flight_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "update_flight_safe_tools"
    return "update_flight_sensitive_tools"
```

- **Explanation:**
  - **`tools_condition(state)`:** Checks if any tool should be called.
  - **`did_cancel`:** If a `CompleteOrEscalate` call is detected, the workflow should exit (return `"leave_skill"`).
  - **Routing Decision:**  
    - If all tool calls are safe, route to `"update_flight_safe_tools"`.
    - Otherwise, route to `"update_flight_sensitive_tools"`.

#### **Connecting the Nodes**

```python
builder.add_edge("update_flight_sensitive_tools", "update_flight")
builder.add_edge("update_flight_safe_tools", "update_flight")
builder.add_conditional_edges(
    "update_flight",
    route_update_flight,
    ["update_flight_sensitive_tools", "update_flight_safe_tools", "leave_skill", END],
)
```

- **Edges:**  
  - Link the tool nodes back to the `update_flight` node.
  - Use conditional edges to decide which node to route next based on the output of `route_update_flight`.

---

### 2️⃣ Common Node: Leaving the Specialized Workflow

```python
def pop_dialog_state(state: State) -> dict:
    """Pop the dialog stack and return to the main assistant."""
    messages = []
    if state["messages"][-1].tool_calls:
        messages.append(
            ToolMessage(
                content="Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.",
                tool_call_id=state["messages"][-1].tool_calls[0]["id"],
            )
        )
    return {
        "dialog_state": "pop",
        "messages": messages,
    }

builder.add_node("leave_skill", pop_dialog_state)
builder.add_edge("leave_skill", "primary_assistant")
```

- **Purpose:**  
  - The `pop_dialog_state` function pops the current workflow from the dialog state (indicating the specialized workflow is done).
  - It then sends a ToolMessage to signal the return to the primary assistant.
- **Edge:**  
  - Connects `"leave_skill"` to `"primary_assistant"`.

---

### 3️⃣ Car Rental Assistant Workflow

#### **Entry Node**

```python
builder.add_node(
    "enter_book_car_rental",
    create_entry_node("Car Rental Assistant", "book_car_rental"),
)
```

- **Handoff:**  
  - Marks the handoff to the **Car Rental Assistant** and sets the dialog state to `"book_car_rental"`.

#### **Assistant Node & Tool Nodes**

```python
builder.add_node("book_car_rental", Assistant(book_car_rental_runnable))
builder.add_edge("enter_book_car_rental", "book_car_rental")
builder.add_node(
    "book_car_rental_safe_tools",
    create_tool_node_with_fallback(book_car_rental_safe_tools),
)
builder.add_node(
    "book_car_rental_sensitive_tools",
    create_tool_node_with_fallback(book_car_rental_sensitive_tools),
)
```

- **Explanation:**  
  - Sets up the car rental assistant using its dedicated runnable and corresponding safe/sensitive tools.

#### **Routing for Car Rental**

```python
def route_book_car_rental(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in book_car_rental_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "book_car_rental_safe_tools"
    return "book_car_rental_sensitive_tools"

builder.add_edge("book_car_rental_sensitive_tools", "book_car_rental")
builder.add_edge("book_car_rental_safe_tools", "book_car_rental")
builder.add_conditional_edges(
    "book_car_rental",
    route_book_car_rental,
    ["book_car_rental_safe_tools", "book_car_rental_sensitive_tools", "leave_skill", END],
)
```

- **Similar Logic:**  
  - Routes between safe and sensitive nodes based on the tool calls, with an option to leave the workflow.

---

### 4️⃣ Hotel Booking & Excursion Workflows

The hotel and excursion workflows follow a similar pattern:

#### **Hotel Booking**

```python
builder.add_node(
    "enter_book_hotel", create_entry_node("Hotel Booking Assistant", "book_hotel")
)
builder.add_node("book_hotel", Assistant(book_hotel_runnable))
builder.add_edge("enter_book_hotel", "book_hotel")
builder.add_node(
    "book_hotel_safe_tools",
    create_tool_node_with_fallback(book_hotel_safe_tools),
)
builder.add_node(
    "book_hotel_sensitive_tools",
    create_tool_node_with_fallback(book_hotel_sensitive_tools),
)
```

- **Routing for Hotel Booking:**

```python
def route_book_hotel(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    tool_names = [t.name for t in book_hotel_safe_tools]
    if all(tc["name"] in tool_names for tc in tool_calls):
        return "book_hotel_safe_tools"
    return "book_hotel_sensitive_tools"

builder.add_edge("book_hotel_sensitive_tools", "book_hotel")
builder.add_edge("book_hotel_safe_tools", "book_hotel")
builder.add_conditional_edges(
    "book_hotel",
    route_book_hotel,
    ["leave_skill", "book_hotel_safe_tools", "book_hotel_sensitive_tools", END],
)
```

#### **Excursion**

```python
builder.add_node(
    "enter_book_excursion",
    create_entry_node("Trip Recommendation Assistant", "book_excursion"),
)
builder.add_node("book_excursion", Assistant(book_excursion_runnable))
builder.add_edge("enter_book_excursion", "book_excursion")
builder.add_node(
    "book_excursion_safe_tools",
    create_tool_node_with_fallback(book_excursion_safe_tools),
)
builder.add_node(
    "book_excursion_sensitive_tools",
    create_tool_node_with_fallback(book_excursion_sensitive_tools),
)
```

- **Routing for Excursion:**

```python
def route_book_excursion(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    tool_names = [t.name for t in book_excursion_safe_tools]
    if all(tc["name"] in tool_names for tc in tool_calls):
        return "book_excursion_safe_tools"
    return "book_excursion_sensitive_tools"

builder.add_edge("book_excursion_sensitive_tools", "book_excursion")
builder.add_edge("book_excursion_safe_tools", "book_excursion")
builder.add_conditional_edges(
    "book_excursion",
    route_book_excursion,
    ["book_excursion_safe_tools", "book_excursion_sensitive_tools", "leave_skill", END],
)
```

---

### 5️⃣ Primary Assistant Workflow

The primary assistant handles general queries and routes tasks to specialized workflows.

```python
builder.add_node("primary_assistant", Assistant(assistant_runnable))
builder.add_node(
    "primary_assistant_tools", create_tool_node_with_fallback(primary_assistant_tools)
)
```

- **Routing Logic for Primary Assistant:**

```python
def route_primary_assistant(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    if tool_calls:
        if tool_calls[0]["name"] == ToFlightBookingAssistant.__name__:
            return "enter_update_flight"
        elif tool_calls[0]["name"] == ToBookCarRental.__name__:
            return "enter_book_car_rental"
        elif tool_calls[0]["name"] == ToHotelBookingAssistant.__name__:
            return "enter_book_hotel"
        elif tool_calls[0]["name"] == ToBookExcursion.__name__:
            return "enter_book_excursion"
        return "primary_assistant_tools"
    raise ValueError("Invalid route")

builder.add_conditional_edges(
    "primary_assistant",
    route_primary_assistant,
    [
        "enter_update_flight",
        "enter_book_car_rental",
        "enter_book_hotel",
        "enter_book_excursion",
        "primary_assistant_tools",
        END,
    ],
)
builder.add_edge("primary_assistant_tools", "primary_assistant")
```

- **Explanation:**
  - The `route_primary_assistant` function checks which specialized tool (represented by a Pydantic model) was called, and routes the conversation to the corresponding entry node.
  - If no specialized tool is detected, it uses `primary_assistant_tools` for general queries.

#### **Returning to Active Workflow**

```python
def route_to_workflow(state: State) -> Literal["primary_assistant", "update_flight", "book_car_rental", "book_hotel", "book_excursion"]:
    """Route directly to the active workflow based on dialog_state."""
    dialog_state = state.get("dialog_state")
    if not dialog_state:
        return "primary_assistant"
    return dialog_state[-1]

builder.add_conditional_edges("fetch_user_info", route_to_workflow)
```

- **Purpose:**  
  - Ensures that when user responses come in, they are directed to the currently active workflow (if any) or to the primary assistant.

---

### 6️⃣ Compiling the Graph

```python
memory = MemorySaver()
part_4_graph = builder.compile(
    checkpointer=memory,
    # Let the user approve or deny the use of sensitive tools
    interrupt_before=[
        "update_flight_sensitive_tools",
        "book_car_rental_sensitive_tools",
        "book_hotel_sensitive_tools",
        "book_excursion_sensitive_tools",
    ],
)
```

- **MemorySaver:**  
  - Saves the state of the conversation (a checkpoint mechanism).
- **`interrupt_before`:**  
  - Specifies nodes where execution is paused to request user confirmation before running sensitive tools.

---

## 🎯 Summary

- **Specialized Workflows:**  
  - Each assistant (flight, car, hotel, excursion) is set up with entry, safe, sensitive, and leave nodes.
  
- **Handoff & Routing:**  
  - Use `create_entry_node` to mark transitions.
  - Conditional routing functions determine whether to use safe or sensitive tools, or whether to exit to the primary assistant.
  
- **Primary Assistant:**  
  - Routes the user's request to the appropriate specialized workflow based on detected intent.
  
- **Graph Compilation:**  
  - Combines all nodes and edges into a single graph, with interruptions for sensitive actions.

This modular design makes the chatbot more **scalable**, **maintainable**, and **user-friendly** by isolating complex logic into focused sub-workflows and providing clear handoffs between agents.

Feel free to ask if you need further clarification or additional examples!

# 🚀 **Understanding Specialized Workflows in a Multi-Agent Chatbot System**

In this guide, we'll break down how to create specialized workflows for a travel booking chatbot. This system assigns a dedicated assistant for each type of task—such as flight updates, hotel bookings, car rentals, and excursion recommendations—with a primary assistant that routes tasks appropriately. We'll explain every part in detail, line by line, and show real-world examples along the way.

---

## 📚 **Overview**

### What Are Specialized Workflows?
- **Specialized Workflows** separate complex tasks into smaller, focused sub-systems.
- Each workflow is managed by its own assistant (agent) that handles a specific domain:
  - ✈️ **Flight Booking Assistant**
  - 🏨 **Hotel Booking Assistant**
  - 🚗 **Car Rental Assistant**
  - 🏔️ **Excursion Assistant**
- A **Primary Assistant** acts as the supervisor that delegates tasks to these specialized assistants using a routing mechanism.

### Why Use This Approach?
- **Modularity:** Each assistant focuses on one domain, making it easier to update or improve without affecting others.
- **User Control:** Sensitive actions (like booking or cancellation) require user confirmation before proceeding.
- **Clarity:** The system clearly separates tasks, so the language model (LLM) is less likely to get confused by mixed contexts.
- **Real-World Example:** Think of a large travel agency where different departments handle flights, hotels, car rentals, and tours. The front desk (primary assistant) directs your inquiry to the appropriate department based on your needs.

---

## 🛠️ **Graph Structure for Specialized Workflows**

In our system, each specialized workflow consists of **5 key nodes**:

1. **Enter Node (enter_*)**  
   Uses the `create_entry_node` utility to insert a **ToolMessage** into the state, signaling the handoff to a specialized assistant.  
2. **Assistant Node**  
   The specialized assistant (e.g., Flight Booking Assistant) takes over with its dedicated prompt and LLM.
3. **Safe Tools Node (\*_safe_tools)**  
   Contains "read-only" tools that do not modify user data and can be used without confirmation.
4. **Sensitive Tools Node (\*_sensitive_tools)**  
   Contains tools that modify user data (e.g., making a booking) and require user confirmation. These nodes are set with `interrupt_before` when the graph is compiled.
5. **Leave Skill Node (leave_skill)**  
   Pops the dialog state to signal that the specialized assistant has finished and control is returned to the primary assistant.

Because these workflows are similar in structure, you could use a factory function to generate them, but here we define each explicitly for clarity.

---

## ✈️ **Flight Booking Assistant Workflow**

### Code Explanation:
```python
# Enter Node: Marks handoff to Flight Booking Assistant
builder.add_node(
    "enter_update_flight",
    create_entry_node("Flight Updates & Booking Assistant", "update_flight"),
)
```
- **Purpose:** Inserts a ToolMessage into the conversation indicating that the **Flight Booking Assistant** is now in control.
- **Parameters:**
  - `"Flight Updates & Booking Assistant"`: The name shown in the ToolMessage.
  - `"update_flight"`: The new dialog state to push onto the stack.

```python
# Assistant Node: The flight booking assistant processes flight updates
builder.add_node("update_flight", Assistant(update_flight_runnable))
builder.add_edge("enter_update_flight", "update_flight")
```
- **Purpose:** Adds the specialized Flight Booking Assistant node and connects it to the enter node.
- **`update_flight_runnable`**: Contains the prompt and LLM bound with flight-specific tools.

```python
# Define nodes for safe and sensitive tools for flight updates
builder.add_node(
    "update_flight_sensitive_tools",
    create_tool_node_with_fallback(update_flight_sensitive_tools),
)
builder.add_node(
    "update_flight_safe_tools",
    create_tool_node_with_fallback(update_flight_safe_tools),
)
```
- **Purpose:** Creates two nodes:
  - **Safe Tools Node:** For read-only tasks (e.g., searching flights).
  - **Sensitive Tools Node:** For write actions (e.g., updating or canceling flights).

### Conditional Routing for Flight Updates:
```python
def route_update_flight(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    # Check if the CompleteOrEscalate tool was invoked (user canceled or escalated)
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in update_flight_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "update_flight_safe_tools"
    return "update_flight_sensitive_tools"
```
- **Purpose:** Routes the conversation based on which tools are being called:
  - If the user cancels (via `CompleteOrEscalate`), return to **leave_skill**.
  - If only safe tools are invoked, continue to the **safe tools node**.
  - Otherwise, route to the **sensitive tools node**.

```python
builder.add_edge("update_flight_sensitive_tools", "update_flight")
builder.add_edge("update_flight_safe_tools", "update_flight")
builder.add_conditional_edges(
    "update_flight",
    route_update_flight,
    ["update_flight_sensitive_tools", "update_flight_safe_tools", "leave_skill", END],
)
```
- **Purpose:** Connects the nodes using conditional edges based on the routing logic defined above.

---

## 🚗 **Car Rental Assistant Workflow**

### Similar Steps for Car Rentals:
- **Enter Node:**  
  ```python
  builder.add_node(
      "enter_book_car_rental",
      create_entry_node("Car Rental Assistant", "book_car_rental"),
  )
  builder.add_node("book_car_rental", Assistant(book_car_rental_runnable))
  builder.add_edge("enter_book_car_rental", "book_car_rental")
  ```
  - Indicates that the **Car Rental Assistant** is now handling the conversation.
  
- **Safe & Sensitive Tools Nodes:**
  ```python
  builder.add_node(
      "book_car_rental_safe_tools",
      create_tool_node_with_fallback(book_car_rental_safe_tools),
  )
  builder.add_node(
      "book_car_rental_sensitive_tools",
      create_tool_node_with_fallback(book_car_rental_sensitive_tools),
  )
  ```
  - Splits the car rental tools into safe and sensitive categories.
  
- **Routing Logic for Car Rentals:**
  ```python
  def route_book_car_rental(state: State):
      route = tools_condition(state)
      if route == END:
          return END
      tool_calls = state["messages"][-1].tool_calls
      did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
      if did_cancel:
          return "leave_skill"
      safe_toolnames = [t.name for t in book_car_rental_safe_tools]
      if all(tc["name"] in safe_toolnames for tc in tool_calls):
          return "book_car_rental_safe_tools"
      return "book_car_rental_sensitive_tools"
  ```
  - Works similarly to the flight routing function, deciding which node to transition to based on tool invocations.
  
- **Connecting Edges:**
  ```python
  builder.add_edge("book_car_rental_sensitive_tools", "book_car_rental")
  builder.add_edge("book_car_rental_safe_tools", "book_car_rental")
  builder.add_conditional_edges(
      "book_car_rental",
      route_book_car_rental,
      ["book_car_rental_safe_tools", "book_car_rental_sensitive_tools", "leave_skill", END],
  )
  ```
  - Ensures proper flow within the car rental assistant workflow.

---

## 🏨 **Hotel Booking and 🏔️ Excursion Assistants**

### Hotel Booking:
- **Enter Node:**
  ```python
  builder.add_node(
      "enter_book_hotel", create_entry_node("Hotel Booking Assistant", "book_hotel")
  )
  builder.add_node("book_hotel", Assistant(book_hotel_runnable))
  builder.add_edge("enter_book_hotel", "book_hotel")
  ```
- **Safe & Sensitive Tools Nodes:**
  ```python
  builder.add_node(
      "book_hotel_safe_tools",
      create_tool_node_with_fallback(book_hotel_safe_tools),
  )
  builder.add_node(
      "book_hotel_sensitive_tools",
      create_tool_node_with_fallback(book_hotel_sensitive_tools),
  )
  ```
- **Routing Logic:**
  ```python
  def route_book_hotel(state: State):
      route = tools_condition(state)
      if route == END:
          return END
      tool_calls = state["messages"][-1].tool_calls
      did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
      if did_cancel:
          return "leave_skill"
      tool_names = [t.name for t in book_hotel_safe_tools]
      if all(tc["name"] in tool_names for tc in tool_calls):
          return "book_hotel_safe_tools"
      return "book_hotel_sensitive_tools"
  ```
- **Edges:**
  ```python
  builder.add_edge("book_hotel_sensitive_tools", "book_hotel")
  builder.add_edge("book_hotel_safe_tools", "book_hotel")
  builder.add_conditional_edges(
      "book_hotel",
      route_book_hotel,
      ["leave_skill", "book_hotel_safe_tools", "book_hotel_sensitive_tools", END],
  )
  ```

### Excursion Assistant:
- Follows the same structure as above with **enter**, **assistant**, **safe tools**, **sensitive tools**, and a **routing function** (`route_book_excursion`).

---

## 🌐 **Primary Assistant Workflow**

The **Primary Assistant** routes tasks to specialized assistants based on user intent.

### Primary Assistant Setup:
```python
builder.add_node("primary_assistant", Assistant(assistant_runnable))
builder.add_node(
    "primary_assistant_tools", create_tool_node_with_fallback(primary_assistant_tools)
)
```
- **Purpose:** The primary assistant can answer general queries and delegate specialized tasks.

### Routing Logic for Primary Assistant:
```python
def route_primary_assistant(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    if tool_calls:
        if tool_calls[0]["name"] == ToFlightBookingAssistant.__name__:
            return "enter_update_flight"
        elif tool_calls[0]["name"] == ToBookCarRental.__name__:
            return "enter_book_car_rental"
        elif tool_calls[0]["name"] == ToHotelBookingAssistant.__name__:
            return "enter_book_hotel"
        elif tool_calls[0]["name"] == ToBookExcursion.__name__:
            return "enter_book_excursion"
        return "primary_assistant_tools"
    raise ValueError("Invalid route")
```
- **Purpose:** Checks the latest tool call from the conversation and routes the user to the appropriate specialized assistant.
- **Example:** If the tool call is `ToBookCarRental`, the user is routed to the **Car Rental Assistant**.

### Connect Primary Assistant Edges:
```python
builder.add_conditional_edges(
    "primary_assistant",
    route_primary_assistant,
    [
        "enter_update_flight",
        "enter_book_car_rental",
        "enter_book_hotel",
        "enter_book_excursion",
        "primary_assistant_tools",
        END,
    ],
)
builder.add_edge("primary_assistant_tools", "primary_assistant")
```
- **Purpose:** Directs flow based on the routing function and returns to the primary assistant after specialized tasks.

### Returning Control to the Active Workflow:
```python
def route_to_workflow(state: State) -> Literal[
    "primary_assistant",
    "update_flight",
    "book_car_rental",
    "book_hotel",
    "book_excursion",
]:
    dialog_state = state.get("dialog_state")
    if not dialog_state:
        return "primary_assistant"
    return dialog_state[-1]

builder.add_conditional_edges("fetch_user_info", route_to_workflow)
```
- **Purpose:** Ensures that when a user responds, the graph knows which specialized assistant should handle the next message.

---

## 💾 **Compiling the Graph**

Finally, we compile the entire graph with memory checkpointing and set interrupts on sensitive tool nodes:
```python
memory = MemorySaver()
part_4_graph = builder.compile(
    checkpointer=memory,
    interrupt_before=[
        "update_flight_sensitive_tools",
        "book_car_rental_sensitive_tools",
        "book_hotel_sensitive_tools",
        "book_excursion_sensitive_tools",
    ],
)
```
- **`MemorySaver()`:** Persists the graph state so that if the conversation is interrupted, it can resume seamlessly.
- **`interrupt_before`:** Ensures that before any sensitive tool is executed, the system pauses for user confirmation.

---

## 🎯 **Key Takeaways**

- **Specialized Workflows:**  
  Each assistant (flight, hotel, car rental, excursion) handles a dedicated task, reducing complexity and improving accuracy.

- **Entry & Exit Nodes:**  
  Entry nodes signal handoff to a specialized assistant using a **ToolMessage**. The exit node (`leave_skill`) pops the dialog state to return control to the primary assistant.

- **Conditional Routing:**  
  Routing functions decide whether to use safe or sensitive tools, or to exit the specialized workflow based on the current state and tool calls.

- **Primary Assistant:**  
  Acts as a supervisor that delegates tasks to the appropriate specialized assistant and routes general queries.

- **Memory and Interrupts:**  
  Memory checkpointing preserves conversation state, and interrupts ensure sensitive actions require user confirmation.

---

## 🌍 **Real-World Application Example**

Imagine an airline’s virtual assistant system:
- A user starts by asking, "I need to change my flight date."
- The **Primary Assistant** interprets this and delegates the request to the **Flight Booking Assistant**.
- The **Flight Booking Assistant** uses safe tools to search for available flights.
- If the user confirms the flight change, the assistant then uses sensitive tools (which require an interrupt for confirmation) to update the booking.
- After the update, control is returned to the **Primary Assistant**, which can handle further queries like hotel bookings or car rentals.

This modular approach ensures that the system remains **robust, flexible, and user-friendly** even as additional features are added.

---

## 🎉 **Conclusion**

By breaking down the chatbot into specialized workflows, we achieve:
- **Enhanced modularity**: Each task is handled by a dedicated assistant.
- **Improved clarity**: The system knows exactly which assistant should handle a given user request.
- **Increased control**: Sensitive actions require user confirmation, reducing errors and increasing trust.

This design is ideal for complex, real-world systems such as airline customer support, where tasks range from simple queries to critical booking updates. With these techniques, you can build scalable and maintainable multi-agent chatbots that deliver excellent user experiences.

If you have any questions or need further clarification, feel free to ask! 😊

# 🌟 **Understanding Specialized Workflows in Assistant Graphs**  

This explanation will break down the **specialized workflows** concept using easy-to-understand language, line-by-line code explanations, real-world examples, and a structured approach with icons for clarity.  

---

## 🚀 **What Are Specialized Workflows?**  

Specialized workflows are like *mini-assistants* within a larger assistant system. Each workflow handles a specific task (like booking flights, renting cars, or reserving hotels) and works together with the primary assistant to provide a seamless user experience.  

### 🌍 **Real-World Example:**  
Imagine a **travel assistant app** where a user can:  
- ✈️ Book or update a flight  
- 🚗 Rent a car  
- 🏨 Book a hotel  
- 🏝️ Plan excursions  

Each task is handled by a different specialized assistant, but the user experiences it as one smooth conversation.  

---

## 🧩 **Key Components of Specialized Workflows**  

Each specialized workflow typically includes:  

1️⃣ **enter_\***: Signals the start of a specialized assistant.  
2️⃣ **Assistant**: The logic that handles user conversations and tasks.  
3️⃣ **\*_safe_tools**: Read-only tools (no user confirmation needed).  
4️⃣ **\*_sensitive_tools**: Write-access tools (need user approval).  
5️⃣ **leave_skill**: Ends the workflow and returns to the primary assistant.  

---

## 🔨 **Step-by-Step Explanation of the Code**  

### 1️⃣ **Create an Entry Node for Specialized Assistants**  
The entry node signals that a new assistant has taken over.

```python
from typing import Callable
from langchain_core.messages import ToolMessage

def create_entry_node(assistant_name: str, new_dialog_state: str) -> Callable:
    def entry_node(state: State) -> dict:
        tool_call_id = state["messages"][-1].tool_calls[0]["id"]
        return {
            "messages": [
                ToolMessage(
                    content=f"The assistant is now the {assistant_name}. Reflect on the above conversation between the host assistant and the user."
                            f" The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are {assistant_name},"
                            " and the booking, update, or other action is not complete until you have successfully invoked the appropriate tool."
                            " If the user changes their mind, call CompleteOrEscalate to return control to the primary assistant.",
                    tool_call_id=tool_call_id,
                )
            ],
            "dialog_state": new_dialog_state,
        }
    return entry_node
```

### 💡 **Explanation:**  
- **`assistant_name`**: Name of the specialized assistant (e.g., "Flight Booking Assistant").  
- **`new_dialog_state`**: The current state, like "update_flight".  
- **`ToolMessage`**: Notifies the system that a specific assistant is now in charge.  
- **`tool_call_id`**: Helps track which action triggered the assistant.  

---

### 2️⃣ **Adding a Flight Booking Workflow**  
This handles tasks like updating or canceling flights.

```python
# Adding the entry point
builder.add_node(
    "enter_update_flight",
    create_entry_node("Flight Updates & Booking Assistant", "update_flight"),
)

# Main assistant logic for flight updates
builder.add_node("update_flight", Assistant(update_flight_runnable))
builder.add_edge("enter_update_flight", "update_flight")

# Safe and sensitive tools
builder.add_node("update_flight_safe_tools", create_tool_node_with_fallback(update_flight_safe_tools))
builder.add_node("update_flight_sensitive_tools", create_tool_node_with_fallback(update_flight_sensitive_tools))
```

### 💡 **Explanation:**  
- **`add_node`**: Adds a task or function.  
- **`add_edge`**: Connects tasks (like linking *enter_update_flight* to *update_flight*).  
- **Safe vs. Sensitive Tools**:  
  - ✅ **Safe tools**: E.g., checking flight details (no user approval).  
  - ⚠️ **Sensitive tools**: E.g., canceling a flight (requires confirmation).  

---

### 3️⃣ **Routing Between Tools**  
Decides which tools to use based on user actions.

```python
def route_update_flight(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    did_cancel = any(tc["name"] == CompleteOrEscalate.__name__ for tc in tool_calls)
    if did_cancel:
        return "leave_skill"
    safe_toolnames = [t.name for t in update_flight_safe_tools]
    if all(tc["name"] in safe_toolnames for tc in tool_calls):
        return "update_flight_safe_tools"
    return "update_flight_sensitive_tools"
```

### 💡 **Explanation:**  
- **`tools_condition`**: Checks which tools are needed.  
- **`did_cancel`**: If the user cancels, it sends control back.  
- **Routing**: Directs to either safe or sensitive tools.  

---

### 4️⃣ **Exiting the Specialized Assistant**  
This brings control back to the main assistant.

```python
def pop_dialog_state(state: State) -> dict:
    messages = []
    if state["messages"][-1].tool_calls:
        messages.append(
            ToolMessage(
                content="Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.",
                tool_call_id=state["messages"][-1].tool_calls[0]["id"],
            )
        )
    return {
        "dialog_state": "pop",
        "messages": messages,
    }

builder.add_node("leave_skill", pop_dialog_state)
builder.add_edge("leave_skill", "primary_assistant")
```

### 💡 **Explanation:**  
- **`pop_dialog_state`**: Pops the state stack, signaling a return to the main assistant.  
- **`leave_skill`**: The transition point between specialized and primary assistants.  

---

### 5️⃣ **Other Specialized Workflows**  
Similarly, we can add workflows for:  
- 🚗 **Car Rentals**  
- 🏨 **Hotel Bookings**  
- 🏝️ **Excursions**  

These workflows follow the **same pattern** as flight booking, just tailored to different tasks.  

---

### 6️⃣ **Primary Assistant Workflow**  
The **primary assistant** manages the entire conversation and delegates tasks to specialized assistants.

```python
builder.add_node("primary_assistant", Assistant(assistant_runnable))
builder.add_node("primary_assistant_tools", create_tool_node_with_fallback(primary_assistant_tools))

def route_primary_assistant(state: State):
    route = tools_condition(state)
    if route == END:
        return END
    tool_calls = state["messages"][-1].tool_calls
    if tool_calls:
        if tool_calls[0]["name"] == ToFlightBookingAssistant.__name__:
            return "enter_update_flight"
        elif tool_calls[0]["name"] == ToBookCarRental.__name__:
            return "enter_book_car_rental"
        elif tool_calls[0]["name"] == ToHotelBookingAssistant.__name__:
            return "enter_book_hotel"
        elif tool_calls[0]["name"] == ToBookExcursion.__name__:
            return "enter_book_excursion"
    return "primary_assistant_tools"

builder.add_conditional_edges(
    "primary_assistant",
    route_primary_assistant,
    [
        "enter_update_flight",
        "enter_book_car_rental",
        "enter_book_hotel",
        "enter_book_excursion",
        "primary_assistant_tools",
        END,
    ],
)
```

### 💡 **Explanation:**  
- **`route_primary_assistant`**: Routes user requests to the correct assistant.  
- **`add_conditional_edges`**: Adds branching based on user requests (like going from flight booking to hotel booking).  

---

## 🏗️ **Compiling the Graph**  
Finally, we compile the entire graph with memory to track progress and interrupts for sensitive tasks.

```python
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()
part_4_graph = builder.compile(
    checkpointer=memory,
    interrupt_before=[
        "update_flight_sensitive_tools",
        "book_car_rental_sensitive_tools",
        "book_hotel_sensitive_tools",
        "book_excursion_sensitive_tools",
    ],
)
```

### 💡 **Explanation:**  
- **`MemorySaver()`**: Keeps track of the conversation history.  
- **`interrupt_before`**: Stops before sensitive actions for user approval.  

---

## 🎯 **Summary of What We Achieved**  
- 🔄 Built **modular workflows** for complex user journeys.  
- 🧭 Implemented **dynamic routing** between specialized assistants.  
- 🔒 Incorporated **safe and sensitive tool usage** with user control.  
- 🔗 Ensured **smooth transitions** between specialized and primary assistants.  

---

## 💬 **Real-World Use Case Recap:**  
Imagine you’re chatting with a travel assistant app:  
- You ask: *"I want to update my flight."* ✈️  
- The assistant routes you to the **Flight Updates Assistant**.  
- After updating the flight, you say: *"Also, I need a hotel."* 🏨  
- The assistant smoothly transitions to the **Hotel Booking Assistant**, handling your request seamlessly.  

This **modular workflow** design ensures complex tasks feel like one smooth conversation! 🚀





# Conversation¶ 

That was a lot! Let's run it over the following list of dialog turns. This time, we'll have many fewer confirmations.

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
    events = part_4_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
    snapshot = part_4_graph.get_state(config)
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
            result = part_4_graph.invoke(
                None,
                config,
            )
        else:
            # Satisfy the tool invocation by
            # providing instructions on the requested changes / change of mind
            result = part_4_graph.invoke(
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
        snapshot = part_4_graph.get_state(config)

```

```js
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

OK cool so it's updated now?
==================================[1m Ai Message [0m==================================

Yes, your flight reservation has been successfully updated. To confirm the new details:

Original Flight:
LX0112 
Paris CDG → Basel BSL
Depart: April 30, 2024 at 2:37 PM
Arrive: April 30, 2024 at 4:07 PM

New Updated Flight:  
LX0112
Paris CDG → Basel BSL  
Depart: May 4, 2024 at 2:37 PM
Arrive: May 4, 2024 at 4:07 PM

Your booking reference remains C46E9F but you have been issued a new ticket number for the updated itinerary. The $100 change fee for modifying your economy fare ticket has been processed, with a new total of $475 charged.

Your reservation is now confirmed for the May 4th flight from Paris to Basel. Please let me know if you need any other details about this updated booking!
================================[1m Human Message [0m=================================

Great - now i want to figure out lodging and transportation.
==================================[1m Ai Message [0m==================================

Sure, I can assist you with booking lodging and transportation for your updated travel dates in Basel. What are your preferences and requirements?

For hotels, some key questions:
- What are your desired check-in and check-out dates in Basel?
- Do you have a particular area or neighborhood you'd like to stay in?
- What is your preferred hotel budget or star rating?
- Do you need any specific room types (single, double, suite, etc)?
- Any other must-have amenities like free breakfast, gym, etc?

And for transportation:
- Will you need a rental car or transportation from/to the Basel airport?
- If a rental, what type of vehicle are you looking for? Any preferences on make/model?
- For how many days would you need the rental car?

Please provide those details and I can look into available hotel and transportation options that fit your needs and travel dates in Basel. Let me know if you need any other information from me at this point.
================================[1m Human Message [0m=================================

Yeah i think i'd like an affordable hotel for my week-long stay (7 days). And I'll want to rent a car.
==================================[1m Ai Message [0m==================================

[{'text': 'Got it, let me look into affordable hotel options in Basel for a 7 night stay, as well as car rental options.\n\nFor the hotel:', 'type': 'text'}, {'id': 'toolu_01J8WG4csfjp7KxBHCvQ7B5U', 'input': {'checkin_date': '2024-05-04', 'checkout_date': '2024-05-11', 'location': 'Basel', 'request': 'Looking for an affordable hotel, around 3-star or lower, for a 7 night stay from May 4-11 in Basel. Prefer something centrally located if possible.'}, 'name': 'BookHotel', 'type': 'tool_use'}]
Tool Calls:
  BookHotel (toolu_01J8WG4csfjp7KxBHCvQ7B5U)
 Call ID: toolu_01J8WG4csfjp7KxBHCvQ7B5U
  Args:
    checkin_date: 2024-05-04
    checkout_date: 2024-05-11
    location: Basel
    request: Looking for an affordable hotel, around 3-star or lower, for a 7 night stay from May 4-11 in Basel. Prefer something centrally located if possible.
Currently in:  book_hotel
=================================[1m Tool Message [0m=================================

The assistant is now the Hotel Booking Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Hotel Booking Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_hotel
==================================[1m Ai Message [0m==================================

[{'text': 'Let me search for affordable hotels in Basel for your 7 night stay from May 4th to May 11th:', 'type': 'text'}, {'id': 'toolu_01GbvksZFaaWLszfCUwJFhVg', 'input': {'checkin_date': '2024-05-04', 'checkout_date': '2024-05-11', 'location': 'Basel', 'price_tier': 'Midscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01GbvksZFaaWLszfCUwJFhVg)
 Call ID: toolu_01GbvksZFaaWLszfCUwJFhVg
  Args:
    checkin_date: 2024-05-04
    checkout_date: 2024-05-11
    location: Basel
    price_tier: Midscale
Currently in:  book_hotel
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 0}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 0}]
Currently in:  book_hotel
==================================[1m Ai Message [0m==================================

[{'text': 'The search returned a few hotel options in Basel, but none in the affordable "Midscale" price tier for your dates. Let me expand the search to include the "Upper Midscale" category as well:', 'type': 'text'}, {'id': 'toolu_01GheLmQeTrtg67NPts3QpLR', 'input': {'checkin_date': '2024-05-04', 'checkout_date': '2024-05-11', 'location': 'Basel', 'price_tier': 'Upper Midscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01GheLmQeTrtg67NPts3QpLR)
 Call ID: toolu_01GheLmQeTrtg67NPts3QpLR
  Args:
    checkin_date: 2024-05-04
    checkout_date: 2024-05-11
    location: Basel
    price_tier: Upper Midscale
Currently in:  book_hotel
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 0}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 0}]
Currently in:  book_hotel
==================================[1m Ai Message [0m==================================

[{'text': 'One option from the search in the "Upper Midscale" tier is the Holiday Inn Basel. It\'s relatively affordable compared to the luxury hotels, and still gets good reviews for its central location and amenities.\n\nWhat do you think about booking the Holiday Inn Basel for your 7 night stay from May 4-11? The rate comes out to $840 total for those dates. Let me know if you\'d like me to go ahead and book that, or if you want me to try a different search.', 'type': 'text'}, {'id': 'toolu_01Kagt1yyDSrjpKNomdXaXxp', 'input': {'cancel': False, 'reason': 'Looking for user confirmation to book the Holiday Inn Basel option for their hotel stay, or if they need me to modify the search instead.'}, 'name': 'CompleteOrEscalate', 'type': 'tool_use'}]
Tool Calls:
  CompleteOrEscalate (toolu_01Kagt1yyDSrjpKNomdXaXxp)
 Call ID: toolu_01Kagt1yyDSrjpKNomdXaXxp
  Args:
    cancel: False
    reason: Looking for user confirmation to book the Holiday Inn Basel option for their hotel stay, or if they need me to modify the search instead.
=================================[1m Tool Message [0m=================================

Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.
==================================[1m Ai Message [0m==================================

For your 7 night hotel stay in Basel from May 4th to May 11th, I was able to find the Holiday Inn Basel which is in the affordable "Upper Midscale" price tier. It has a central location and decent amenities.

The total rate for those dates at the Holiday Inn Basel would be $840.

Does this hotel option work for you, or would you like me to try a different search? I'm happy to modify the price range or location preferences. Just let me know if you need any other details or if you'd like me to go ahead and book the Holiday Inn Basel for those dates.
================================[1m Human Message [0m=================================

OK could you place a reservation for your recommended hotel? It sounds nice. Feel free to choose for me
==================================[1m Ai Message [0m==================================

[{'text': "Sounds good, I'll go ahead and book your reservation at the Holiday Inn Basel for your 7 night stay from May 4th to May 11th.", 'type': 'text'}, {'id': 'toolu_01GvBYmrUmQbHeEF9ZaQXGr1', 'input': {'checkin_date': '2024-05-04', 'checkout_date': '2024-05-11', 'location': 'Basel', 'request': 'Please book a reservation at the Holiday Inn Basel for 7 nights from May 4th to May 11th, 2024 for 1 room.'}, 'name': 'BookHotel', 'type': 'tool_use'}]
Tool Calls:
  BookHotel (toolu_01GvBYmrUmQbHeEF9ZaQXGr1)
 Call ID: toolu_01GvBYmrUmQbHeEF9ZaQXGr1
  Args:
    checkin_date: 2024-05-04
    checkout_date: 2024-05-11
    location: Basel
    request: Please book a reservation at the Holiday Inn Basel for 7 nights from May 4th to May 11th, 2024 for 1 room.
Currently in:  book_hotel
=================================[1m Tool Message [0m=================================

The assistant is now the Hotel Booking Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Hotel Booking Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_hotel
==================================[1m Ai Message [0m==================================

[{'text': 'Great, confirming the booking details:\n\nHotel: Holiday Inn Basel\nDates: Check-in May 4th, 2024 - Check-out May 11th, 2024 (7 nights)\nRoom: 1 standard room ', 'type': 'text'}, {'id': 'toolu_01QvycKUpzRdMhC4HmNucEMg', 'input': {'hotel_id': 8}, 'name': 'book_hotel', 'type': 'tool_use'}]
Tool Calls:
  book_hotel (toolu_01QvycKUpzRdMhC4HmNucEMg)
 Call ID: toolu_01QvycKUpzRdMhC4HmNucEMg
  Args:
    hotel_id: 8
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

yes go ahead and book anything that's moderate expense and has availability.
==================================[1m Ai Message [0m==================================

[{'text': "Got it, I'll book a moderately priced rental car option for you in Basel with the best availability during your stay from May 4th-11th.", 'type': 'text'}, {'id': 'toolu_01JUPB1tguBJ6ksx1xGDqbtv', 'input': {'end_date': '2024-05-11', 'location': 'Basel', 'request': 'Please book a moderately priced rental car (economy or compact class) for pickup and return in Basel from May 4th to May 11th, 2024.', 'start_date': '2024-05-04'}, 'name': 'BookCarRental', 'type': 'tool_use'}]
Tool Calls:
  BookCarRental (toolu_01JUPB1tguBJ6ksx1xGDqbtv)
 Call ID: toolu_01JUPB1tguBJ6ksx1xGDqbtv
  Args:
    end_date: 2024-05-11
    location: Basel
    request: Please book a moderately priced rental car (economy or compact class) for pickup and return in Basel from May 4th to May 11th, 2024.
    start_date: 2024-05-04
Currently in:  book_car_rental
=================================[1m Tool Message [0m=================================

The assistant is now the Car Rental Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Car Rental Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_car_rental
==================================[1m Ai Message [0m==================================

[{'text': 'Let me check for available rental cars in Basel for the dates of May 4th to May 11th:', 'type': 'text'}, {'id': 'toolu_011kbSNRwDdVAmdhbR7RUsNi', 'input': {'end_date': '2024-05-11', 'location': 'Basel', 'price_tier': 'Midscale', 'start_date': '2024-05-04'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_011kbSNRwDdVAmdhbR7RUsNi)
 Call ID: toolu_011kbSNRwDdVAmdhbR7RUsNi
  Args:
    end_date: 2024-05-11
    location: Basel
    price_tier: Midscale
    start_date: 2024-05-04
Currently in:  book_car_rental
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 0}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
Currently in:  book_car_rental
==================================[1m Ai Message [0m==================================

[{'text': 'The search returned a few rental options in Basel for your dates, but nothing yet in the moderately priced "Midscale" tier. Let me expand to include the "Midsize" tier as well:', 'type': 'text'}, {'id': 'toolu_0152vc2SVWpSY4fxeo14jCEZ', 'input': {'end_date': '2024-05-11', 'location': 'Basel', 'price_tier': 'Midsize', 'start_date': '2024-05-04'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_0152vc2SVWpSY4fxeo14jCEZ)
 Call ID: toolu_0152vc2SVWpSY4fxeo14jCEZ
  Args:
    end_date: 2024-05-11
    location: Basel
    price_tier: Midsize
    start_date: 2024-05-04
Currently in:  book_car_rental
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 0}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
Currently in:  book_car_rental
==================================[1m Ai Message [0m==================================

[{'text': 'The Thrifty rental in Basel shows availability for a midsize vehicle during your dates of May 4-11. The total rate for an 8 day midsize rental comes out to $425.\n\nWould you like me to go ahead and book the midsize rental from Thrifty for your stay in Basel? It fits the moderate pricing you requested. Or let me know if you need me to look at any other options.', 'type': 'text'}, {'id': 'toolu_01Go8zSbkyX5gSFAqozJZ6mM', 'input': {'cancel': False, 'reason': 'Looking for confirmation from the user to book the Thrifty rental car option in Basel for May 4-11, or if they need any other rental options.'}, 'name': 'CompleteOrEscalate', 'type': 'tool_use'}]
Tool Calls:
  CompleteOrEscalate (toolu_01Go8zSbkyX5gSFAqozJZ6mM)
 Call ID: toolu_01Go8zSbkyX5gSFAqozJZ6mM
  Args:
    cancel: False
    reason: Looking for confirmation from the user to book the Thrifty rental car option in Basel for May 4-11, or if they need any other rental options.
=================================[1m Tool Message [0m=================================

Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.
==================================[1m Ai Message [0m==================================

For your car rental needs in Basel from May 4th to May 11th, I was able to find availability for a midsize vehicle from Thrifty. The total rate for the 8 day rental comes out to $425, which fits the moderate pricing you requested.

Does the midsize rental from Thrifty work for you? If so, I can go ahead and confirm that booking. Or if you need me to look at any other rental car options in Basel for those dates, just let me know.
================================[1m Human Message [0m=================================

Now for a car, what are my options?
==================================[1m Ai Message [0m==================================

For your rental car in Basel from May 4th to May 11th, here are a couple of the available options I found:

Midsize Vehicle from Thrifty
- Vehicle Class: Midsize (e.g. Toyota Corolla or similar)
- Pick-up/Drop-off: Basel Airport or City locations
- Total Rate: $425 for 8 days

Economy Vehicle from Europcar
- Vehicle Class: Economy (e.g. Volkswagen Polo or similar) 
- Pick-up/Drop-off: Basel Airport or City locations
- Total Rate: $375 for 8 days

I can provide some additional details on those rentals from Thrifty and Europcar if needed. The Thrifty midsize option was around $425 total, while the Europcar economy option is a bit less at $375 total for your dates.

Let me know if either of those rental options work for your needs in Basel. Or if you had a different vehicle class or rental company preference, I'm happy to check on additional availability as well. Just provide any other requirements you have for the rental car and I can get you some updated options.
================================[1m Human Message [0m=================================

Awesome let's just get the cheapest option. Go ahead and book for 7 days
==================================[1m Ai Message [0m==================================

[{'text': "Sounds good, let's book the most economical rental car option for your 7 day stay in Basel.", 'type': 'text'}, {'id': 'toolu_011Mjizn1KMrayddMtReRkUa', 'input': {'end_date': '2024-05-11', 'location': 'Basel', 'request': 'Please book the cheapest available rental car option (economy or compact class) for pickup and return in Basel from May 4th to May 11th, 2024.', 'start_date': '2024-05-04'}, 'name': 'BookCarRental', 'type': 'tool_use'}]
Tool Calls:
  BookCarRental (toolu_011Mjizn1KMrayddMtReRkUa)
 Call ID: toolu_011Mjizn1KMrayddMtReRkUa
  Args:
    end_date: 2024-05-11
    location: Basel
    request: Please book the cheapest available rental car option (economy or compact class) for pickup and return in Basel from May 4th to May 11th, 2024.
    start_date: 2024-05-04
Currently in:  book_car_rental
=================================[1m Tool Message [0m=================================

The assistant is now the Car Rental Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Car Rental Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_car_rental
==================================[1m Ai Message [0m==================================

[{'text': 'Okay, let me book the cheapest available rental car option for your dates in Basel:', 'type': 'text'}, {'id': 'toolu_01Aixx27dJjqiibJao1tDarB', 'input': {'end_date': '2024-05-11', 'location': 'Basel', 'start_date': '2024-05-04'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_01Aixx27dJjqiibJao1tDarB)
 Call ID: toolu_01Aixx27dJjqiibJao1tDarB
  Args:
    end_date: 2024-05-11
    location: Basel
    start_date: 2024-05-04
Currently in:  book_car_rental
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 0}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
Currently in:  book_car_rental
==================================[1m Ai Message [0m==================================

[{'text': 'The cheapest available rental for your 7 day stay from May 4-11 is the economy vehicle from Europcar for $375 total.', 'type': 'text'}, {'id': 'toolu_01HwvJpe7cdX8BkF2C28z9py', 'input': {'rental_id': 1}, 'name': 'book_car_rental', 'type': 'tool_use'}]
Tool Calls:
  book_car_rental (toolu_01HwvJpe7cdX8BkF2C28z9py)
 Call ID: toolu_01HwvJpe7cdX8BkF2C28z9py
  Args:
    rental_id: 1
``````output
Do you approve of the above actions? Type 'y' to continue; otherwise, explain your requested changed.

 y
``````output
================================[1m Human Message [0m=================================

Cool so now what recommendations do you have on excursions?
==================================[1m Ai Message [0m==================================

[{'text': 'For recommendations on excursions and activities during your stay in Basel, I can transfer you to our dedicated excursions assistant who specializes in local tours and attractions. They can provide some personalized suggestions based on your interests.', 'type': 'text'}, {'id': 'toolu_016v6PDgXV4535hQ9JDggU4A', 'input': {'location': 'Basel', 'request': 'The customer will be staying in Basel from May 4-11 and is looking for recommendations on excursions, tours, activities or other things to do during their week-long visit to the area. Please provide some options tailored to their interests.'}, 'name': 'BookExcursion', 'type': 'tool_use'}]
Tool Calls:
  BookExcursion (toolu_016v6PDgXV4535hQ9JDggU4A)
 Call ID: toolu_016v6PDgXV4535hQ9JDggU4A
  Args:
    location: Basel
    request: The customer will be staying in Basel from May 4-11 and is looking for recommendations on excursions, tours, activities or other things to do during their week-long visit to the area. Please provide some options tailored to their interests.
Currently in:  book_excursion
=================================[1m Tool Message [0m=================================

The assistant is now the Trip Recommendation Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Trip Recommendation Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_excursion
==================================[1m Ai Message [0m==================================

[{'text': "Great, let me put together some recommendations for excursions and activities to enjoy during your week-long stay in Basel from May 4th-11th.\n\nSome options to consider:\n\n- Take a walking tour of Basel's charming Old Town to see sights like the red sandstone Basel Münster cathedral and vibrant Marktplatz square.\n\n- Visit the Fondation Beyeler art museum which houses an excellent collection of modern/contemporary artworks by artists like Picasso, Warhol, and more. \n\n- Go for a cruise along the Rhine River that flows through Basel.\n\n- Take a day trip to explore neighboring areas like the scenic Swiss village of Bremgarten or even visit Colmar, France which is just over the border.\n\n- If the weather is nice, hike or bike through the sunny vineyards and villages of the Basel countryside.\n\n- Check out the Basel Paper Mill Museum to learn about the region's papermaking history.\n\nLet me know if any of those ideas appeal to you or if you'd prefer recommendations tailored towards other interests like history, art, cuisine, family activities, etc. I'm happy to provide more personalized Basel excursion options.", 'type': 'text'}, {'id': 'toolu_015JVzyXGPiKuoLMuKoF3gme', 'input': {'cancel': False, 'reason': "Provided some initial excursion recommendations for things to do in Basel during the user's upcoming stay and awaiting their feedback or other interests to further narr ... (truncated)
=================================[1m Tool Message [0m=================================

Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.
==================================[1m Ai Message [0m==================================

For your week-long stay in Basel from May 4th - 11th, here are some potential excursions and activities I would recommend:

- Take a walking tour of the charming Basel Old Town to see highlights like Basel Münster cathedral and Marktplatz
- Visit the excellent Fondation Beyeler art museum 
- Take a scenic cruise along the Rhine River
- Do a day trip to nearby areas like Bremgarten village or Colmar, France
- Go hiking or biking through the Basel vineyards and countryside
- Check out the Basel Paper Mill Museum

Those cover a mix of history, culture, outdoors, and general sightseeing in and around Basel. But I'm happy to provide other recommendations if you have particular interests like art, cuisine, family activities, or anything else. Just let me know what kind of excursions appeal to you most and I can suggest some curated options to make the most of your time in Basel.
================================[1m Human Message [0m=================================

Are they available while I'm there?
==================================[1m Ai Message [0m==================================

[{'text': 'Good point, let me double check availability for those Basel excursion recommendations during your specific travel dates of May 4th - 11th.\n\nWalking Tours of Old Town Basel\n- These run daily year-round, so walking tours should be available during your stay. I can book a guided tour or provide a self-guided route.\n\nFondation Beyeler Art Museum\n- The museum is open Tuesday-Sunday, so it will be operating during your visit next week. I can look into reserved entry times if needed.\n\nRhine River Cruises \n- Let me confirm cruise schedules and availability for early May:', 'type': 'text'}, {'id': 'toolu_01Xr5qzdnZDQjRuY72h2fttz', 'input': {'activity': 'Rhine River Cruise', 'location': 'Basel', 'start_date': '2024-05-04', 'end_date': '2024-05-11'}, 'name': 'check_availability', 'type': 'tool_use'}]
Tool Calls:
  check_availability (toolu_01Xr5qzdnZDQjRuY72h2fttz)
 Call ID: toolu_01Xr5qzdnZDQjRuY72h2fttz
  Args:
    activity: Rhine River Cruise
    location: Basel
    start_date: 2024-05-04
    end_date: 2024-05-11
=================================[1m Tool Message [0m=================================

Error: KeyError('check_availability')
 please fix your mistakes.
==================================[1m Ai Message [0m==================================

My apologies, I don't have direct access to check availability calendars. In general, river cruises do operate during the early May timeframe in Basel, but let me reach out to verify schedules for your specific dates.

For the day trips to areas like Bremgarten or Colmar, those can be self-guided excursions, so availability is open.

And the Basel Paper Mill Museum is open Wednesday-Sunday, so it should have operating hours during your stay as well.

Let me know if you need any other details validated in terms of availability for those Basel activities from May 4th-11th. I'm happy to confirm schedules where possible before booking anything.
================================[1m Human Message [0m=================================

interesting - i like the outdoors. OK great let's book that then.
==================================[1m Ai Message [0m==================================

[{'text': "Got it, since you mentioned enjoying outdoor activities, let's focus on booking an excursion that showcases the beautiful natural scenery around Basel.\n\nBased on my initial recommendations, I think going hiking or biking through the vineyards and villages in the Basel countryside would be a great outdoor option during your stay next week.", 'type': 'text'}, {'id': 'toolu_01R1xCvXzTx1HvCvtjEr5fVX', 'input': {'location': 'Basel', 'request': 'Please book a guided hiking or biking tour through the vineyards and rural villages outside of Basel for sometime during the week of May 4-11, 2024. Preference for an outdoor nature/scenery focused excursion.'}, 'name': 'BookExcursion', 'type': 'tool_use'}]
Tool Calls:
  BookExcursion (toolu_01R1xCvXzTx1HvCvtjEr5fVX)
 Call ID: toolu_01R1xCvXzTx1HvCvtjEr5fVX
  Args:
    location: Basel
    request: Please book a guided hiking or biking tour through the vineyards and rural villages outside of Basel for sometime during the week of May 4-11, 2024. Preference for an outdoor nature/scenery focused excursion.
Currently in:  book_excursion
=================================[1m Tool Message [0m=================================

The assistant is now the Trip Recommendation Assistant. Reflect on the above conversation between the host assistant and the user. The user's intent is unsatisfied. Use the provided tools to assist the user. Remember, you are Trip Recommendation Assistant, and the booking, update, other other action is not complete until after you have successfully invoked the appropriate tool. If the user changes their mind or needs help for other tasks, call the CompleteOrEscalate function to let the primary host assistant take control. Do not mention who you are - just act as the proxy for the assistant.
Currently in:  book_excursion
==================================[1m Ai Message [0m==================================

[{'text': 'Sounds like the perfect excursion for you! Let me look into available guided hiking and biking tours showcasing the scenic Basel countryside during your stay next week.', 'type': 'text'}, {'id': 'toolu_01QU6mk1NhNeRWTtaiChkhuN', 'input': {'keywords': 'hiking, biking, nature, scenery, vineyards, villages', 'location': 'Basel', 'start_date': '2024-05-04', 'end_date': '2024-05-11'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01QU6mk1NhNeRWTtaiChkhuN)
 Call ID: toolu_01QU6mk1NhNeRWTtaiChkhuN
  Args:
    keywords: hiking, biking, nature, scenery, vineyards, villages
    location: Basel
    start_date: 2024-05-04
    end_date: 2024-05-11
Currently in:  book_excursion
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
Currently in:  book_excursion
==================================[1m Ai Message [0m==================================

[{'text': "Hmm it doesn't look like my initial search pulled up any vineyard hiking or biking tours for those dates. Let me try expanding the search:", 'type': 'text'}, {'id': 'toolu_019K14VeBY9LANAZgrqTNNso', 'input': {'keywords': 'outdoors, nature, countryside, bike tour, hike', 'location': 'Basel', 'start_date': '2024-05-01', 'end_date': '2024-05-15'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_019K14VeBY9LANAZgrqTNNso)
 Call ID: toolu_019K14VeBY9LANAZgrqTNNso
  Args:
    keywords: outdoors, nature, countryside, bike tour, hike
    location: Basel
    start_date: 2024-05-01
    end_date: 2024-05-15
Currently in:  book_excursion
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
Currently in:  book_excursion
==================================[1m Ai Message [0m==================================

[{'text': "Unfortunately I'm still not getting any relevant outdoor excursion results for the timeframe of your Basel trip next month. It seems the typical vineyard tours and countryside hikes may not be fully operating that early in the season.\n\nRather than book something that may not meet your interests, would you prefer I look into a different type of outdoor activity in Basel? Or if hiking/biking was a top priority, I could check dates later in the spring/summer instead. Let me know how you'd like to proceed.", 'type': 'text'}, {'id': 'toolu_012zNixgoDeUc1spskZ3xSyM', 'input': {'cancel': False, 'reason': "Unable to find a suitable vineyard hiking or biking tour available for the user's dates in Basel next month. Need guidance on if they want to explore other outdoor options or different dates."}, 'name': 'CompleteOrEscalate', 'type': 'tool_use'}]
Tool Calls:
  CompleteOrEscalate (toolu_012zNixgoDeUc1spskZ3xSyM)
 Call ID: toolu_012zNixgoDeUc1spskZ3xSyM
  Args:
    cancel: False
    reason: Unable to find a suitable vineyard hiking or biking tour available for the user's dates in Basel next month. Need guidance on if they want to explore other outdoor options or different dates.
=================================[1m Tool Message [0m=================================

Resuming dialog with the host assistant. Please reflect on the past conversation and assist the user as needed.
==================================[1m Ai Message [0m==================================

Unfortunately I was unable to find any available guided hiking or biking tours through the vineyards and countryside around Basel for your specific travel dates of May 4th - 11th. It seems many of those tours may not be fully operating until later in the spring/summer season.

Since getting an outdoor excursion was important to you, I have a couple options:

1) I can look into other outdoor activity recommendations in Basel for early May, like city walking tours, park visits, river cruises, etc. 

2) If a vineyard/countryside hiking or biking tour is a top priority, I can check availability for later dates when those seasonal offerings are more active.

Let me know which direction you'd prefer - exploring alternative outdoor options for your May dates, or pushing the vineyard tour to later in the season. I'm happy to adjust my recommendation either way to find something fitting your interests.
```

# Conclusion:¶
You've now developed a customer support bot that handles diverse tasks using focused workflows. More importantly, you've learned to use some of LangGraph's core features to design and refactor an application based on your product needs.

The above examples are by no means optimized for your unique needs - LLMs make mistakes, and each flow can be made more reliable through better prompts and experimentation. Once you've created your initial support bot, the next step would be to start adding evaluations so you can confidently improve your system. Check out those docs and our other tutorials to learn more!

# 🚀 **Conversation Execution in a Multi-Agent Chatbot System**

This section explains how the specialized workflows and multi-agent system are **executed in a real conversation**. We'll walk through the code that simulates a conversation, describe each part in detail, and explain the purpose behind each code segment. This setup ensures that user inputs are processed, and if sensitive actions are to be executed, the user is asked for confirmation.

---

## 📌 **Overview**

- **Purpose:**  
  Run a conversation over multiple dialog turns with our multi-agent chatbot system.  
- **Key Features:**  
  - **State Restoration:** Uses a backup database to start fresh each time.  
  - **Unique Thread ID:** Distinguishes each conversation session.
  - **User Confirmation:** Pauses before executing sensitive actions for user approval.
  - **Event Streaming:** Processes each dialog turn and prints the responses.
  
- **Real-World Example:**  
  Imagine a travel booking assistant that processes a user's queries. It asks for confirmation before making changes like booking a flight or hotel, ensuring the user is always in control.

---

## 🔧 **Step-by-Step Code Explanation**

### 1. **Initialization and Configuration**

```python
import shutil
import uuid

# Update with the backup file so we can restart from the original place in each section
db = update_dates(db)
thread_id = str(uuid.uuid4())
```

- **`import shutil, uuid`**:  
  - **shutil:** For file operations (used to manage backups).  
  - **uuid:** Generates unique identifiers.

- **`db = update_dates(db)`**:  
  - **Purpose:** Updates the database with current dates.  
  - **Why?** Ensures that every run starts from a consistent state.

- **`thread_id = str(uuid.uuid4())`**:  
  - **Purpose:** Creates a unique identifier for the conversation session.  
  - **Real-World Use:** Similar to a unique session ID in a web application, ensuring the conversation is tracked separately.

---

### 2. **Setting Up the Configuration**

```python
config = {
    "configurable": {
        "passenger_id": "3442 587242",  # Used to fetch user's flight information
        "thread_id": thread_id,         # Links conversation to the unique thread ID
    }
}
```

- **`config` Dictionary:**  
  - **`passenger_id`:**  
    - **Purpose:** Identifies the user so that flight-related tools can fetch their specific data.
  - **`thread_id`:**  
    - **Purpose:** Associates the conversation with a unique session, used for checkpoints and resuming conversations.

---

### 3. **Processing Each Dialog Turn**

```python
_printed = set()
# We can reuse the tutorial questions from part 1 to see how it does.
for question in tutorial_questions:
    events = part_4_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
```

- **`_printed = set()`**:  
  - **Purpose:** Keeps track of printed events to avoid duplicate outputs.

- **Loop Over `tutorial_questions`:**  
  - **Purpose:** Simulates a conversation by processing each user query.
  
- **`part_4_graph.stream(...)`:**  
  - **Parameters:**
    - **`{"messages": ("user", question)}`:**  
      - Wraps the user’s question into a message.
    - **`config`:**  
      - Provides configuration (passenger_id, thread_id).
    - **`stream_mode="values"`:**  
      - Indicates that the output will be streamed (processed piece-by-piece).
  - **Result:** Returns a stream of events (responses from the chatbot).

- **`_print_event(event, _printed)`:**  
  - **Purpose:** Prints each event (response) while avoiding duplicates.

---

### 4. **Handling Interrupts for Sensitive Actions**

```python
    snapshot = part_4_graph.get_state(config)
    while snapshot.next:
        try:
            user_input = input(
                "Do you approve of the above actions? Type 'y' to continue;"
                " otherwise, explain your requested changed.\n\n"
            )
        except:
            user_input = "y"
        if user_input.strip() == "y":
            result = part_4_graph.invoke(
                None,
                config,
            )
        else:
            result = part_4_graph.invoke(
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
        snapshot = part_4_graph.get_state(config)
```

- **`snapshot = part_4_graph.get_state(config)`**:  
  - **Purpose:** Retrieves the current state of the conversation from the graph.

- **`while snapshot.next:`**:  
  - **Purpose:** Checks if there is an interrupt—i.e., if the graph is waiting for user confirmation before proceeding with a sensitive action.

- **User Confirmation via `input()`:**  
  - **Try/Except Block:**  
    - **Purpose:** Prompts the user to approve or deny the action.  
    - **`user_input`:** If the user types "y", it means approval; otherwise, the user provides a reason for denial.

- **Handling Approval:**
  ```python
  if user_input.strip() == "y":
      result = part_4_graph.invoke(None, config)
  ```
  - **Purpose:**  
    - **`invoke(None, config)`:** Resumes the graph execution with the current state because the user approved the action.

- **Handling Denial:**
  ```python
  else:
      result = part_4_graph.invoke(
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
  - **Purpose:**  
    - Sends a **ToolMessage** with the user's reasoning for denying the action.
    - This informs the chatbot to adjust its behavior accordingly.
    
- **Updating the Snapshot:**
  ```python
  snapshot = part_4_graph.get_state(config)
  ```
  - **Purpose:** Re-checks the state after processing the user's input. The loop continues until there are no more interrupts.

---

## 🔑 **Key Takeaways**

- **State Restoration and Unique Session:**  
  Ensures every conversation starts fresh and is tracked independently using `thread_id`.

- **Configuration:**  
  Passes necessary user information (like `passenger_id`) to tools for personalized responses.

- **Event Streaming:**  
  Processes each dialog turn, prints responses, and handles repeated outputs with `_printed`.

- **Interrupt Handling:**  
  Pauses execution before sensitive actions to ask for user confirmation. This is crucial for safety and user control.

- **ToolMessage for Denial:**  
  Sends a detailed message back to the system if a user denies an action, ensuring that the chatbot can adapt and continue assisting.

---

## 🌍 **Real-World Example**

Imagine you're using a travel assistant app to modify your flight booking:

1. **User:** "I need to change my flight to next Monday."
2. **Assistant:** Searches for available flights and prepares an update.
3. **Interrupt:** Before making the change, the assistant asks, "Do you approve of the above changes?"  
   - **User:** Types "y" if they agree, or explains changes if they don't.
4. **Assistant:** If approved, it completes the booking; if denied, it adjusts its actions based on the user's input.

This mechanism ensures that any **sensitive actions** (like modifying a booking) require explicit user confirmation, reducing errors and ensuring trust.

---

## 🎉 **Conclusion**

This code block simulates a real conversation with a **multi-agent chatbot** that:
- **Streams user queries and responses.**
- **Uses configuration to personalize interactions.**
- **Pauses for user confirmation on sensitive actions.**

By following this approach, you ensure that your chatbot is both **powerful and safe**, giving users full control over critical operations. This design is ideal for complex applications like travel booking, banking, or healthcare, where user consent is paramount.

Feel free to ask if you need further clarification or more examples! 😊


# 🚀 Running the Conversation in Our Multi-Agent Chatbot

In this section, we simulate an entire conversation using our **Part 4 graph**. The conversation runs through several dialog turns, handling user queries, and managing interruptions for sensitive actions—all while involving specialized workflows.

Below is the detailed code snippet with line-by-line explanations, examples, and real-world context.

---

## 🔑 Overview

- **Purpose:**  
  - To simulate a complete conversation with our chatbot.
  - To show how the graph processes each dialog turn and handles interrupts (user confirmations) for sensitive actions.
  
- **Real-World Example:**  
  Imagine you're using a travel assistant app. You ask questions like "What time is my flight?" or "Update my booking." The assistant processes your requests, but before performing a sensitive action (like changing a booking), it pauses and asks, "Do you approve?" This code simulates that entire interactive process.

---

## 📝 Code Example with Explanations

```python
import shutil
import uuid

# Update with the backup file so we can restart from the original place in each section
db = update_dates(db)
thread_id = str(uuid.uuid4())

config = {
    "configurable": {
        # The passenger_id is used in our flight tools to fetch the user's flight information
        "passenger_id": "3442 587242",
        # Checkpoints are accessed by thread_id (each conversation is unique)
        "thread_id": thread_id,
    }
}
```

### 🔍 Explanation:
- **`import shutil, uuid`:**  
  - `shutil` may be used for file operations (e.g., updating backups).
  - `uuid` generates a unique identifier for each conversation thread.
- **`update_dates(db)`:**  
  - Resets or updates the database backup so the conversation can start fresh.
- **`thread_id = str(uuid.uuid4())`:**  
  - Creates a unique ID to track the current conversation.
- **`config`:**  
  - A dictionary that holds configuration details such as `passenger_id` and `thread_id`.  
  - These details help our tools fetch the correct user information and maintain conversation state.

---

```python
_printed = set()
# We can reuse the tutorial questions from part 1 to see how it does.
for question in tutorial_questions:
    events = part_4_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
```

### 🔍 Explanation:
- **`_printed = set()`:**  
  - A set to track which events have already been printed. This prevents duplicate outputs.
- **`for question in tutorial_questions:`**  
  - Iterates over a list of pre-defined user questions.
- **`part_4_graph.stream(...)`:**  
  - Streams events (or messages) from the conversation graph for the given user query.
  - The `config` is passed to ensure proper state context.
  - `stream_mode="values"` tells the system to stream only the values (the responses) from the graph.
- **`_print_event(event, _printed)`:**  
  - A helper function that prints each event if it hasn’t been printed before.

---

```python
    snapshot = part_4_graph.get_state(config)
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
            # Just continue the conversation without changes.
            result = part_4_graph.invoke(
                None,
                config,
            )
        else:
            # Satisfy the tool invocation by providing instructions on requested changes.
            result = part_4_graph.invoke(
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
        snapshot = part_4_graph.get_state(config)
```

### 🔍 Explanation:
- **`snapshot = part_4_graph.get_state(config)`:**  
  - Retrieves the current state of the conversation after processing the user's query.
- **`while snapshot.next:`**  
  - Checks if the graph is in an **interrupt state** (i.e., waiting for user confirmation before proceeding).
- **`try/except` block:**  
  - Prompts the user for confirmation using `input()`.  
  - If there's an exception (e.g., in non-interactive environments), it defaults to `"y"`.
- **`if user_input.strip() == "y":`**  
  - If the user approves (types `"y"`), the graph is invoked to continue with the current action.
- **`else:`**  
  - If the user provides an explanation (or denies the action), the graph is invoked with a **ToolMessage** containing the user's reason.
  - **`ToolMessage(...)`:**  
    - Includes the tool call ID to tie the message to the current interrupted action.
    - Contains a message explaining that the API call was denied and includes the user’s reasoning.
- **`snapshot = part_4_graph.get_state(config)`:**  
  - Updates the conversation state after processing the user's decision.
  - The loop continues until there are no more pending interrupts.

---

## 💡 Real-World Context

Imagine you're interacting with your travel assistant on your smartphone:
- **User:** "Update my flight to next week."
- **Assistant:** Processes your request and then pauses, showing the planned action and asking, "Do you approve?"
- **You:** Type "y" if you agree, or type "No, I want a different time."
- The assistant then either proceeds with the update or adjusts based on your feedback.

This interactive process helps ensure that **sensitive actions** (like updating a booking) are only performed with your explicit approval.

---

## 🎯 Summary

- **Setting Up:**  
  - We update our database backup and set a unique thread ID for the conversation.
  - A configuration object (`config`) is created to store critical user data.
  
- **Streaming the Conversation:**  
  - We iterate over a list of tutorial questions, stream the events from our conversation graph, and print them.
  
- **Handling Interrupts:**  
  - After each query, the graph's state is checked.
  - If an interrupt is detected (waiting for confirmation), the user is prompted.
  - The conversation continues based on whether the user approves the action or provides alternative instructions.

This process ensures that the chatbot's actions are transparent and under user control, improving both **security** and **user satisfaction**.

Feel free to ask any questions if you need further clarification or additional examples!