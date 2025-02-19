# ✈️ **Build a Customer Support Bot for an Airline**  

Customer support bots help businesses by automating responses to common queries, saving time, and enhancing customer experience. In this tutorial, we will build a **customer support bot** for an **airline** that assists users with:  
- Booking flights  
- Reserving hotels  
- Renting cars  
- Suggesting excursions  

We'll use **LangGraph**, **Claude (LLM)**, and **SQLite database**. We'll also integrate **web search** using **Tavily**.  

By the end of this tutorial, you'll:  
✅ Understand LangGraph's key concepts like **interrupts**, **checkpointers**, and **complex states**.  
✅ Build a fully functional airline customer support chatbot.  
✅ Be able to apply these patterns to other AI projects.  

---

## 🌟 **Real-World Use Case**  
Imagine you're running an airline company like **Emirates** or **Qatar Airways**. You want to reduce the workload on customer service teams by automating tasks like:  
- Booking flight tickets  
- Managing hotel and car rental queries  
- Providing travel recommendations  

A chatbot can handle these tasks 24/7, improving customer satisfaction and cutting operational costs.  

---

## 🛠️ **Prerequisites**  
Before we dive into coding, let’s set up our environment.  

### ✅ **Step 1: Install Required Libraries**  
We'll install the following libraries:  
- `langgraph`: For creating graph-based workflows.  
- `langchain-community`: For community integrations.  
- `langchain-anthropic`: To use Claude LLM.  
- `tavily-python`: For web search integration.  
- `pandas`: For handling data.  
- `openai`: For OpenAI’s API access.

### 💻 **Code: Install Packages**  
```python
%%capture --no-stderr
%pip install -U langgraph langchain-community langchain-anthropic tavily-python pandas openai
```

### 📝 **Explanation**  
- `%%capture --no-stderr`: Jupyter magic command to suppress output.  
- `%pip install -U`: Installs the packages and upgrades them if they exist.  
- The listed packages will enable our bot to perform various tasks like searching the web, managing databases, and using AI models.  

---

### 🔒 **Step 2: Set Up API Keys**  
To interact with AI models and perform web searches, we need API keys. We’ll securely set them using Python's `os` and `getpass` libraries.  

### 💻 **Code: Set Environment Variables**  
```python
import getpass
import os

def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

# Set API keys for external services
_set_env("ANTHROPIC_API_KEY")
_set_env("OPENAI_API_KEY")
_set_env("TAVILY_API_KEY")
```

### 📝 **Explanation**  
- **`import getpass`**: For secure input of sensitive data like API keys.  
- **`import os`**: To manage environment variables.  
- **`_set_env()`**:  
  - Checks if the variable exists in the environment.  
  - If not, prompts the user securely to enter the key.  
- **Why environment variables?** ✅ They protect sensitive data from being hardcoded into the script.  

---

## 🌐 **Step 3: Setting Up LangSmith for Debugging**  
**LangSmith** allows you to debug, test, and monitor your LLM apps. It uses trace data to analyze the performance of your LangGraph projects.  

**Why LangSmith?**  
- Quickly spot and fix issues  
- Visualize the flow of your chatbot  
- Optimize LLM performance  

### 💡 **Real-World Example:**  
If your bot fails to book a flight, LangSmith will help you see where the issue occurred — whether it's the database query, LLM misunderstanding, or API connection.

---

## 🏗️ **Next Steps**  
1️⃣ Connect a **SQLite database** to store flight, hotel, and car rental data.  
2️⃣ Build **custom tools** that:  
   - Search for flights  
   - Book hotels  
   - Rent cars  
   - Suggest excursions  
3️⃣ Integrate **Claude (LLM)** for natural language understanding.  
4️⃣ Use **LangGraph interrupts and checkpointers** to manage conversation flow.

---

## 💡 **Example Use Case in Action**  
**Scenario:**  
A customer wants to book a flight from **Karachi** to **Dubai**, rent a car, and book a hotel.  

### 🛫 **Bot Conversation Flow:**  
1. **User**: "I want to fly from Karachi to Dubai on 10th March."  
2. **Bot**: "Available flights on 10th March are Emirates EK-601 at 10 AM and PIA PK-213 at 2 PM. Which one would you prefer?"  
3. **User**: "Emirates EK-601."  
4. **Bot**: "Flight booked! Would you like to reserve a hotel or rent a car in Dubai?"  
5. **User**: "Yes, I need both."  
6. **Bot**: "Here are some hotels and rental options. Please choose your preferences."  

---

## 🔄 **Explaining LangGraph Concepts with Examples**  

### 🔀 **Interrupts**  
Interrupts help pause the conversation when the bot needs more information from the user.  
**Example:**  
- If the user says "Book a flight," but doesn’t mention the destination, the bot will pause and ask, "Where would you like to go?"  

### 💾 **Checkpointers**  
Checkpointers save the state of the conversation so that the bot can resume if interrupted.  
**Example:**  
- If the user books a flight but leaves before confirming hotel details, the bot will remember the last step and continue from there when the user returns.  

---

## 💬 **Next Section Teaser:**  
✨ In the next section, we’ll:  
- Build the **SQLite database** for flight, hotel, and car rental data.  
- Implement **functions** to query this database.  
- Create **LangGraph nodes** for each booking step.  

Would you like me to continue with the database and function implementation? 😊