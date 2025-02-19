

# Part 1: Zero-shot Agent¶ 

**When building, it's best to start with the simplest working implementation and use an evaluation tool like LangSmith to measure its efficacy. All else equal, prefer simple, scalable solutions to complicated ones. In this case, the single-graph approach has limitations. The bot may take undesired actions without user confirmation, struggle with complex queries, and lack focus in its responses. We'll address these issues later.**

In this section, we will define a simple Zero-shot agent as the assistant, give the agent all of our tools, and prompt it to use them judiciously to assist the user.

The simple 2-node graph will look like the following:



**Start by defining the state.**



# State¶
 
Define our StateGraph's state as a typed dictionary containing an append-only list of messages. These messages form the chat history, which is all the state our simple assistant needs.

```python
from typing import Annotated

from typing_extensions import TypedDict

from langgraph.graph.message import AnyMessage, add_messages


class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
API Reference: add_messages
```


# Agent¶ 

Next, define the assistant function. This function takes the graph state, formats it into a prompt, and then calls an LLM for it to predict the best response.

```python
from langchain_anthropic import ChatAnthropic
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable, RunnableConfig


class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            configuration = config.get("configurable", {})
            passenger_id = configuration.get("passenger_id", None)
            state = {**state, "user_info": passenger_id}
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
# You could swap LLMs, though you will likely want to update the prompts when
# doing so!
# from langchain_openai import ChatOpenAI

# llm = ChatOpenAI(model="gpt-4-turbo-preview")

primary_assistant_prompt = ChatPromptTemplate.from_messages(
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

part_1_tools = [
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
part_1_assistant_runnable = primary_assistant_prompt | llm.bind_tools(part_1_tools)
```

# 🚀 **Building a Zero-Shot Agent with LangChain**  

In this detailed guide, we'll break down how to create a **Zero-Shot Agent** using **LangChain**, explain each part with line-by-line code explanations, and use beginner-friendly language. Icons and headings will make this explanation engaging and easy to follow.

---

## 🌟 **What is a Zero-Shot Agent?**  
A **Zero-Shot Agent** is an AI assistant that responds to user queries **without prior training on specific tasks**, relying only on the instructions provided at runtime. It’s like giving a smart assistant some tools and asking it to figure things out on the fly!  

### ✈️ **Real-World Example:**  
Imagine you’re building a chatbot for **Swiss Airlines** that can:  
- Search flights  
- Book hotels  
- Manage car rentals  
- Answer customer questions  

The bot uses its tools **only when necessary** and **responds thoughtfully** based on user queries.

---

## 📑 **Main Sections Covered**  
1️⃣ **Defining the State** (Chat History Management)  
2️⃣ **Building the Assistant Function** (Agent Behavior)  
3️⃣ **Prompting the Agent** (Telling the Bot How to Think)  
4️⃣ **Connecting Tools to the Agent** (Enabling Bot Actions)  

---

## 1️⃣ 🌐 **Defining the State**  

The **state** holds the **chat history** between the user and the bot. This history helps the bot understand the conversation context.  

### 💻 **Code Example & Explanation:**

```python
from typing import Annotated
from typing_extensions import TypedDict
from langgraph.graph.message import AnyMessage, add_messages

class State(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]
```

### 🔍 **Explanation:**  
- **`TypedDict`**: Creates a dictionary with specific key-value pairs. Here, it defines what data the **state** holds.  
- **`messages`**: Stores **all chat messages** (from user & bot).  
- **`Annotated`**: Adds extra meaning to the list—**`add_messages`** ensures new messages are appended, preserving chat history.  

### 📝 **Why This Matters:**  
Without maintaining chat history, the bot would forget previous conversations, making it less effective.

---

## 2️⃣ 🤖 **Building the Assistant Function**  

This function defines **how the bot responds** using an LLM (**Large Language Model**) like Claude or GPT.  

### 💻 **Code Example & Explanation:**

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.runnables import Runnable, RunnableConfig

class Assistant:
    def __init__(self, runnable: Runnable):
        self.runnable = runnable  # ⚡ Assigns the LLM model

    def __call__(self, state: State, config: RunnableConfig):
        while True:
            configuration = config.get("configurable", {})
            passenger_id = configuration.get("passenger_id", None)  # 🛂 Get user info
            state = {**state, "user_info": passenger_id}

            result = self.runnable.invoke(state)  # 🤖 LLM generates a response

            # 🚨 Re-prompt if LLM gives empty response
            if not result.tool_calls and (
                not result.content
                or isinstance(result.content, list) and not result.content[0].get("text")
            ):
                messages = state["messages"] + [("user", "Respond with a real output.")]
                state = {**state, "messages": messages}
            else:
                break
        return {"messages": result}  # 📩 Return the final response
```

### 🔍 **Explanation (Line by Line):**  
- **`self.runnable = runnable`**: Stores the LLM model for later use.  
- **`config.get("configurable", {})`**: Retrieves additional configuration, like **user details**.  
- **`result = self.runnable.invoke(state)`**: The model predicts the **next message** based on the current state.  
- **Error Handling**: If the model’s response is empty, the bot **re-prompts** for a valid answer.  

### 🎯 **What This Achieves:**  
This logic ensures the bot:  
✅ Understands user context (like passenger ID)  
✅ Doesn’t return empty or meaningless responses  

---

## 3️⃣ 📝 **Prompting the Agent**  

A **prompt** tells the bot **what role to play** and **how to respond**.  

### 💻 **Code Example:**

```python
from langchain_core.prompts import ChatPromptTemplate
from datetime import datetime

primary_assistant_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful customer support assistant for Swiss Airlines. "
            "Use the provided tools to search for flights, company policies, and other information. "
            "Be persistent and expand your search if no results are found."
            "\n\nCurrent user:\n<User>\n{user_info}\n</User>"
            "\nCurrent time: {time}.",
        ),
        ("placeholder", "{messages}"),
    ]
).partial(time=datetime.now)
```

### 🔍 **Explanation:**  
- **Role Instruction**: The assistant is told it’s a **Swiss Airlines support agent**.  
- **Behavior Guidance**: It’s instructed to:  
  - 🔄 **Retry searches** if no results are found.  
  - 🧭 **Use tools carefully** to help the user.  
- **Dynamic Info**: Adds the **current time** and **user info** dynamically.  
- **`{messages}`**: A placeholder for the **conversation history**.  

### ✨ **Example Bot Response Prompted by This:**
```
Hello! I see you’re interested in booking a flight. Let me check the latest options for you.
```

---

## 4️⃣ 🛠️ **Connecting Tools to the Agent**  

Now we connect various **tools** that the bot can use (like searching flights, booking hotels, etc.).  

### 💻 **Code Example:**

```python
from langchain_community.tools.tavily_search import TavilySearchResults

part_1_tools = [
    TavilySearchResults(max_results=1),  # 🌐 Search tool
    fetch_user_flight_information,       # ✈️ Fetch flight info
    search_flights,                      # 🔍 Search flights
    lookup_policy,                       # 📜 Lookup policies
    update_ticket_to_new_flight,          # 🔄 Update tickets
    cancel_ticket,                        # ❌ Cancel tickets
    search_hotels,                        # 🏨 Search hotels
    book_hotel,                           # 📅 Book hotel
    cancel_hotel,                         # ❎ Cancel hotel booking
]

part_1_assistant_runnable = primary_assistant_prompt | llm.bind_tools(part_1_tools)
```

### 🔍 **Explanation:**  
- **`TavilySearchResults`**: Searches the web for relevant information.  
- **`fetch_user_flight_information`**: Retrieves a user’s flight details.  
- **`search_flights`, `book_hotel`, `cancel_ticket`**: Various tools for handling travel-related tasks.  
- **`llm.bind_tools(part_1_tools)`**: **Binds** these tools to the **LLM**, enabling the bot to call them when necessary.  

### ⚡ **Example Interaction:**  
**User:** "Can you find flights from Zurich to Paris tomorrow?"  
**Bot (using tools):** "Sure! Let me search for available flights... ✈️"  

---

## 🎯 **Key Takeaways**  
| 🏷️ **Component**              | 📝 **Purpose**                                           | 🔥 **Example**                     |
|------------------------------|---------------------------------------------------------|------------------------------------|
| **State**                    | Stores conversation history                              | Remembers previous user queries.  |
| **Assistant Function**       | Defines how the bot uses the LLM to respond               | Calls the LLM and re-prompts if empty. |
| **Prompt**                   | Guides the bot’s behavior and tone                       | "Be persistent when searching."   |
| **Tools**                    | Enables the bot to take actions (search, book, cancel)    | Searches flights or books hotels. |

---

## 🚀 **Final Thoughts**  

You’ve now learned how to:  
✅ Define a chat assistant’s state  
✅ Build an AI agent with meaningful behavior  
✅ Guide it using prompts  
✅ Connect real-world tools for dynamic interactions  

✨ **With these skills, you can build powerful AI assistants for customer support, travel booking, and more!**  

💬 **Let me know if you want further examples or explanations on advanced topics like multi-node graphs!** 😊