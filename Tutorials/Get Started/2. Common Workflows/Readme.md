# 🚀 **Understanding Workflows and Agents in Agentic Systems**  

Agentic systems are gaining popularity in AI because they make AI models smarter by helping them manage complex tasks. To fully understand how these systems work, we need to explore two key concepts: **Workflows** and **Agents**. We will cover these concepts with real-world examples, detailed code explanations, and step-by-step breakdowns.  

---

## 🌟 **What are Workflows?**  

### 💡 **Definition:**  
**Workflows** are **predefined sequences of tasks** that an AI model (LLM) and tools follow. They are like recipes—each step is planned in advance.  

### 🌍 **Real-World Example:**  
Imagine an **e-commerce website** where a customer places an order. The workflow could look like this:  
1. ✅ Confirm the order.  
2. 🚚 Arrange shipping.  
3. 💳 Process the payment.  
4. 📩 Send an email confirmation.  

Each step follows a fixed sequence without any decision-making by the system.  

---

## 🤖 **What are Agents?**  

### 💡 **Definition:**  
**Agents** are AI systems that can **decide what to do next** based on the task. They can dynamically choose which tools to use and how to complete tasks.  

### 🌍 **Real-World Example:**  
Consider a **virtual travel assistant** helping you plan a vacation. It can:  
- ✈️ Suggest flights based on your preferences.  
- 🏨 Recommend hotels based on your budget.  
- 🍽️ Book restaurants depending on your dietary needs.  

Unlike workflows, the agent adapts its actions based on your inputs and changing conditions.  

---

## 🔄 **Key Differences Between Workflows and Agents**  

| ⚡ **Feature**      | 🛠️ **Workflows**                          | 🤖 **Agents**                          |
|---------------------|-------------------------------------------|-----------------------------------------|
| **Task Control**    | Predefined by developers                  | Dynamically decided by the AI           |
| **Flexibility**     | Low (fixed sequence)                      | High (can adapt based on context)       |
| **Example**         | Order processing in e-commerce            | Personal assistant for trip planning    |
| **Complexity**      | Simple to moderate                        | Complex (needs decision-making ability) |

---

## 🛠️ **Setting Up the Environment**  

Before we start building, we need to set up our environment by installing necessary packages and initializing our model.  

### 🔧 **Step 1: Install Dependencies**  
```bash
pip install langchain langchain-anthropic pydantic
```
- `langchain`: Framework for building LLM-powered applications.  
- `langchain-anthropic`: Integration for using Anthropic's LLM.  
- `pydantic`: Helps in creating data models for structured outputs.  

---

### 🗝️ **Step 2: Initialize the LLM**  
```python
import os
import getpass
from langchain_anthropic import ChatAnthropic

# 🔑 Function to set the API key securely
def _set_env(var: str):
    if not os.environ.get(var):
        os.environ[var] = getpass.getpass(f"{var}: ")

# 🚀 Setting the API key for Anthropic's model
_set_env("ANTHROPIC_API_KEY")

# 🤖 Initializing the Claude model from Anthropic
llm = ChatAnthropic(model="claude-3-5-sonnet-latest")
```

### 🔍 **Explanation:**  
- **`_set_env` function:** Checks if the API key exists in the environment; if not, it prompts the user.  
- **`ChatAnthropic` model:** Initializes the Claude-3-5 Sonnet model, which is a conversational AI model from Anthropic.  

---

## 🏗️ **Building Blocks: The Augmented LLM**  

### ✨ **What is an Augmented LLM?**  
An **augmented LLM** can:  
- ✅ Provide **structured outputs** (well-defined data instead of just plain text).  
- 🛠️ Use **tools** like calculators or search functions.  

---

### 📝 **Step 3: Structured Outputs with Pydantic**  
```python
from pydantic import BaseModel, Field

# 📚 Defining a schema for structured output
class SearchQuery(BaseModel):
    search_query: str = Field(None, description="Query optimized for web search.")
    justification: str = Field(None, description="Why this query is relevant.")

# 🔗 Augmenting the LLM with the structured output schema
structured_llm = llm.with_structured_output(SearchQuery)

# 🔍 Invoking the augmented LLM
output = structured_llm.invoke("How does Calcium CT score relate to high cholesterol?")

# 📤 Displaying the output
print(output)
```

### 💡 **Explanation:**  
- **`SearchQuery` class:** Defines a model with two fields:  
  - `search_query`: The actual search string.  
  - `justification`: The reason for choosing this search.  
- **`with_structured_output`:** Tells the LLM to return data in this structured format.  
- **`invoke`:** Calls the LLM with a question and gets structured results.  

### 🌍 **Real-World Use Case:**  
A **healthcare assistant** using structured outputs to search for relevant medical information based on user symptoms.  

---

### ⚡ **Step 4: Tool Calling in LLM**  

#### 🔢 **Example: Basic Math Tool**  
```python
# 🔧 Defining a simple multiplication tool
def multiply(a: int, b: int) -> int:
    return a * b

# 🧩 Augmenting the LLM with the multiplication tool
llm_with_tools = llm.bind_tools([multiply])

# 🚀 Invoking the LLM with a query that uses the tool
msg = llm_with_tools.invoke("What is 2 times 3?")

# 🔎 Displaying the tool call output
print(msg.tool_calls)
```

### 💡 **Explanation:**  
- **`multiply` function:** A simple function to multiply two numbers.  
- **`bind_tools`:** Attaches the tool to the LLM, so it can use it when needed.  
- **`invoke`:** The LLM intelligently decides to use the `multiply` function for the query.  

### 🌍 **Real-World Use Case:**  
A **financial assistant** calculating loan payments or investment growth based on user input.  

---

## 🧭 **Key Takeaways**  
- **Workflows:** Fixed, sequential processes suitable for repetitive tasks.  
- **Agents:** Flexible, decision-making systems ideal for complex, dynamic scenarios.  
- **LangGraph + Langchain:** Help build workflows and agents with features like persistence, debugging, and deployment.  
- **Augmented LLM:** Enhanced LLM with structured outputs and tool-calling abilities.  

---

## 🎯 **Conclusion**  
Understanding how to build workflows and agents using LLMs opens up countless possibilities. From healthcare and e-commerce to finance and personal assistance, these systems enable AI to handle complex, real-world tasks efficiently.  

Would you like more advanced examples or real-world project ideas on this topic? 😊

Here’s a detailed explanation of **Prompt Chaining** with clear headings, icons for better understanding, real-world use cases, and **step-by-step code explanations** for beginners. 🚀

---

# 🌟 **What is Prompt Chaining?**

**Prompt Chaining** is a technique where multiple **LLM (Large Language Model)** calls are linked together. The output of one call becomes the input for the next. This approach is like solving a big problem by breaking it into smaller, manageable parts.

### 💡 **Key Idea:**  
Each model call solves part of the task, passing results along the chain until the final goal is reached.

---

# 🎯 **Why Use Prompt Chaining?**

Prompt chaining is useful when:
- A task can be broken down into **simple subtasks**.  
- You want **higher accuracy** by validating intermediate steps.  
- The **sequence of steps** matters for the final output.

---

# 🌍 **Real-World Examples of Prompt Chaining**  

1️⃣ **Content Generation:**  
Writing a blog post where:
- Step 1: Generate an outline.  
- Step 2: Write sections for each heading.  
- Step 3: Proofread and improve the content.  

2️⃣ **Customer Support Automation:**  
- Step 1: Understand customer query.  
- Step 2: Search for a relevant solution.  
- Step 3: Generate a summarized response.

3️⃣ **Joke Generation (Our Example):**  
- Step 1: Generate a basic joke.  
- Step 2: Improve it with wordplay.  
- Step 3: Add a surprising twist for humor.

---

# ⚡ **When Should You Use Prompt Chaining?**  
- ✅ When accuracy is more important than speed.  
- ✅ For tasks requiring **step-by-step validation**.  
- ✅ If **context builds** from one step to the next.

---

# 🛠️ **Step-by-Step Code Explanation: Prompt Chaining in Action**

Let’s break down the code example you provided, explaining each line and its purpose.

---

## 📦 **Import Required Libraries**

```python
from langgraph.func import entrypoint, task
```
✅ **Explanation:**  
- `entrypoint`: Defines the **starting point** of our workflow.  
- `task`: Marks functions as tasks so they can be executed as part of the workflow.

---

## 😂 **Step 1: Generate a Joke**
```python
@task
def generate_joke(topic: str):
    """First LLM call to generate initial joke"""
    msg = llm.invoke(f"Write a short joke about {topic}")
    return msg.content
```
✅ **Explanation:**  
- **@task**: Marks this function as a task in the workflow.  
- **llm.invoke()**: Calls the language model, asking it to write a joke about the given **topic**.  
- **msg.content**: Extracts and returns the actual joke from the model’s response.

---

## 🧐 **Step 2: Check if the Joke Has a Punchline**
```python
def check_punchline(joke: str):
    """Gate function to check if the joke has a punchline"""
    if "?" in joke or "!" in joke:
        return "Fail"
    return "Pass"
```
✅ **Explanation:**  
- A **gate function** checks if the joke has a proper **punchline**.  
- If the joke contains **?** or **!**, it’s likely incomplete or not funny enough, so it returns **"Fail"**.  
- Otherwise, it returns **"Pass"** for further processing.

---

## 🎭 **Step 3: Improve the Joke with Wordplay**
```python
@task
def improve_joke(joke: str):
    """Second LLM call to improve the joke"""
    msg = llm.invoke(f"Make this joke funnier by adding wordplay: {joke}")
    return msg.content
```
✅ **Explanation:**  
- **Goal:** Make the joke **funnier** by adding clever wordplay.  
- **llm.invoke()**: Asks the model to enhance the joke with **puns or creative word use**.

---

## 😲 **Step 4: Add a Surprising Twist**
```python
@task
def polish_joke(joke: str):
    """Third LLM call for final polish"""
    msg = llm.invoke(f"Add a surprising twist to this joke: {joke}")
    return msg.content
```
✅ **Explanation:**  
- Adds an **unexpected element** to make the joke more surprising and engaging.  
- The **final polish** ensures the joke is punchy and complete.

---

## 🔄 **Step 5: Combine Everything with a Workflow**
```python
@entrypoint()
def parallel_workflow(topic: str):
    original_joke = generate_joke(topic).result()
    if check_punchline(original_joke) == "Pass":
        return original_joke

    improved_joke = improve_joke(original_joke).result()
    return polish_joke(improved_joke).result()
```
✅ **Explanation:**  
- **@entrypoint**: This is where the entire workflow starts.  
- The **original joke** is generated.  
- If it passes the punchline check, it’s returned immediately.  
- Otherwise, the joke is **improved** and then **polished** for the final result.

---

## 🚀 **Step 6: Running the Workflow**
```python
# Invoke
for step in parallel_workflow.stream("cats", stream_mode="updates"):
    print(step)
    print("\n")
```
✅ **Explanation:**  
- **parallel_workflow.stream("cats")**: Runs the workflow for the topic **"cats"**.  
- **stream_mode="updates"**: Shows updates for each step in real-time.  
- **print(step)**: Displays the joke at each step.

---

# 📝 **Output Example (Cats Joke)**  
```
Why was the cat sitting on the computer?  
Because it wanted to keep an eye on the mouse!  
```

---

# 🎈 **Why Prompt Chaining is Powerful**  
- 🔄 **Step-by-step improvement:** Each LLM call **refines** the result.  
- ✅ **Validation checks:** Ensure output **quality** at each stage.  
- 🌐 **Adaptable:** Useful for any **multi-step** language processing task.

---

# 🌟 **Final Thoughts**

Prompt chaining ensures complex tasks are solved by breaking them into **smaller, manageable tasks** with **higher accuracy**. From **content generation** to **automated customer support**, prompt chaining is a **powerful technique** for building smarter AI systems.

---

# 🌟 **Understanding Parallelization in LLM Workflows**

Parallelization allows **Large Language Models (LLMs)** to handle multiple tasks simultaneously, boosting efficiency and accuracy. Let's break this concept down step by step, making it beginner-friendly, with **real-world examples**, **code explanations**, and **icons** for visual appeal. 🚀

---

## 🎯 **What is Parallelization?**

Parallelization means executing **multiple tasks at the same time** instead of one after another. In the context of LLMs, you can assign independent subtasks to run simultaneously and combine their results later.

### 💡 **Key Variations of Parallelization:**
1. **⚡ Sectioning:** Break a task into smaller, independent subtasks processed at the same time.
2. **🗳️ Voting:** Run the **same task** multiple times to get **diverse outputs** and pick the best one.

---

## 🌐 **Real-World Example: Content Creation for a Blog**

Imagine you’re running a **blog about pets** 🐱 and want to create **engaging content**. You need:
- A **story** 📝 about cats.
- A **joke** 😂 to keep readers entertained.
- A **poem** ✍️ to add a creative touch.

Instead of writing these one by one, you can **parallelize** the process, generating all three at once. This reduces time while maintaining quality.

---

## 🔧 **When to Use Parallelization?**
- ✅ When tasks are **independent** of each other.
- ✅ When you need **faster results**.
- ✅ When you want **multiple perspectives** for better quality (e.g., brainstorming ideas).

---

## 💻 **Code Example with Detailed Explanation**

Let's walk through the **Python code** that shows **parallelization** using LLM calls. We’ll generate a joke, story, and poem about a topic (**"cats"**) and then combine them.

---

### 🔨 **Step 1: Import Required Modules**

```python
from langgraph.func import entrypoint, task
```
- **Purpose:**  
  - `@entrypoint`: Marks the **starting point** of the workflow.
  - `@task`: Decorates functions to define them as **tasks** in the workflow.

---

### 📝 **Step 2: Define Tasks to Run in Parallel**

#### 1️⃣ **Generate a Joke about the Topic**
```python
@task
def call_llm_1(topic: str):
    """First LLM call to generate initial joke"""
    msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content
```
- **What it does:** Requests the LLM to **write a joke** about the given topic.
- **Line-by-line explanation:**
  - `@task`: Marks the function as a parallel task.
  - `msg = llm.invoke(...)`: Calls the LLM with a prompt.
  - `return msg.content`: Returns the generated joke.

---

#### 2️⃣ **Generate a Story about the Topic**
```python
@task
def call_llm_2(topic: str):
    """Second LLM call to generate story"""
    msg = llm.invoke(f"Write a story about {topic}")
    return msg.content
```
- **Purpose:** LLM generates a **short story** based on the topic.
- **Key logic:** Same as the joke function but focuses on storytelling.

---

#### 3️⃣ **Generate a Poem about the Topic**
```python
@task
def call_llm_3(topic):
    """Third LLM call to generate poem"""
    msg = llm.invoke(f"Write a poem about {topic}")
    return msg.content
```
- **Purpose:** Produces a **creative poem** on the topic.

---

### 🔄 **Step 3: Combine All Outputs (Aggregator Function)**

```python
@task
def aggregator(topic, joke, story, poem):
    """Combine the joke, story, and poem into a single output"""
    combined = f"Here's a story, joke, and poem about {topic}!\n\n"
    combined += f"STORY:\n{story}\n\n"
    combined += f"JOKE:\n{joke}\n\n"
    combined += f"POEM:\n{poem}"
    return combined
```
- **What it does:** Merges all the generated content into one structured output.
- **Explanation:**
  - `combined`: A formatted string containing the story, joke, and poem.
  - The `+=` operator appends each piece to the final message.

---

### 🚀 **Step 4: Build and Run the Workflow**

```python
@entrypoint()
def parallel_workflow(topic: str):
    joke_fut = call_llm_1(topic)
    story_fut = call_llm_2(topic)
    poem_fut = call_llm_3(topic)
    return aggregator(
        topic, joke_fut.result(), story_fut.result(), poem_fut.result()
    ).result()
```
- **Explanation:**
  - **Parallel execution:** `call_llm_1`, `call_llm_2`, and `call_llm_3` run **simultaneously**.
  - `.result()`: Waits for each parallel task to complete before combining them.

---

### 🎬 **Step 5: Invoke the Workflow**

```python
for step in parallel_workflow.stream("cats", stream_mode="updates"):
    print(step)
    print("\n")
```
- **Purpose:**  
  - Runs the **parallel workflow** for the topic **"cats"** 🐈.
  - **`stream_mode="updates"`**: Shows output as tasks complete.
  - **`print(step)`**: Displays each step's result.

---

## 🌍 **Real-World Applications of Parallelization**

1. **🌐 Content Generation:**  
   - Blogs needing articles, jokes, and poems generated simultaneously.
   - Social media posts with different content formats (tweets, captions, stories).

2. **🛍️ E-commerce Product Descriptions:**  
   - Generate multiple product descriptions for different audiences at once.

3. **💬 Multilingual Translations:**  
   - Translate the same content into multiple languages simultaneously.

4. **📊 Data Analysis Reports:**  
   - Create separate summaries, graphs, and insights in parallel for faster reporting.

---

## 🏆 **Benefits of Parallelization**
- ⚡ **Speed:** Completes tasks faster by working on them simultaneously.
- 🔍 **Accuracy:** Handles complex problems by focusing on specific subtasks.
- 🌈 **Diversity:** Generates **multiple perspectives** for richer outputs.

---

## 🚨 **Key Takeaways:**
- **Parallelization** breaks large tasks into smaller parts, running them together for efficiency.  
- Ideal for scenarios requiring **speed**, **diversity of output**, and **complex content generation**.
- The approach reduces waiting time and improves overall performance.

---

💬 *Do you want to explore more complex parallelization scenarios or have specific questions about how to implement this in your projects?* 😊

# Complete Code of Functional API (beta)
```python
@task
def call_llm_1(topic: str):
    """First LLM call to generate initial joke"""
    msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content


@task
def call_llm_2(topic: str):
    """Second LLM call to generate story"""
    msg = llm.invoke(f"Write a story about {topic}")
    return msg.content


@task
def call_llm_3(topic):
    """Third LLM call to generate poem"""
    msg = llm.invoke(f"Write a poem about {topic}")
    return msg.content


@task
def aggregator(topic, joke, story, poem):
    """Combine the joke and story into a single output"""

    combined = f"Here's a story, joke, and poem about {topic}!\n\n"
    combined += f"STORY:\n{story}\n\n"
    combined += f"JOKE:\n{joke}\n\n"
    combined += f"POEM:\n{poem}"
    return combined


# Build workflow
@entrypoint()
def parallel_workflow(topic: str):
    joke_fut = call_llm_1(topic)
    story_fut = call_llm_2(topic)
    poem_fut = call_llm_3(topic)
    return aggregator(
        topic, joke_fut.result(), story_fut.result(), poem_fut.result()
    ).result()

# Invoke
for step in parallel_workflow.stream("cats", stream_mode="updates"):
    print(step)
    print("\n")

```

# Complete Code of Graph API
```python
@task
def call_llm_1(topic: str):
    """First LLM call to generate initial joke"""
    msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content


@task
def call_llm_2(topic: str):
    """Second LLM call to generate story"""
    msg = llm.invoke(f"Write a story about {topic}")
    return msg.content


@task
def call_llm_3(topic):
    """Third LLM call to generate poem"""
    msg = llm.invoke(f"Write a poem about {topic}")
    return msg.content


@task
def aggregator(topic, joke, story, poem):
    """Combine the joke and story into a single output"""

    combined = f"Here's a story, joke, and poem about {topic}!\n\n"
    combined += f"STORY:\n{story}\n\n"
    combined += f"JOKE:\n{joke}\n\n"
    combined += f"POEM:\n{poem}"
    return combined


# Build workflow
@entrypoint()
def parallel_workflow(topic: str):
    joke_fut = call_llm_1(topic)
    story_fut = call_llm_2(topic)
    poem_fut = call_llm_3(topic)
    return aggregator(
        topic, joke_fut.result(), story_fut.result(), poem_fut.result()
    ).result()

# Invoke
for step in parallel_workflow.stream("cats", stream_mode="updates"):
    print(step)
    print("\n")

```
Here’s a **detailed and beginner-friendly explanation** of the **Routing** concept, complete with real-world examples, code breakdown, and easy explanations of each line of code. I'll use headings, icons, and clear explanations for better understanding.  

---

# 🌟 **Understanding Routing in LLM Workflows**  

---

## 📚 **What is Routing?**  

**Routing** in LLM (Large Language Model) workflows refers to the process of classifying an input and directing it to a specific follow-up task.  

💡 **Key Idea:** Instead of handling all inputs the same way, we **route** them based on what they are asking for. This ensures that each request is handled using the most appropriate process.  

---

### 🌍 **Real-World Example of Routing**  
Imagine you’re running a **customer service chatbot** for an online store. Users ask different questions:  
- **“What is my order status?”** — 📝 Route to **order tracking** module  
- **“I want to return an item.”** — 🔄 Route to **returns** module  
- **“Tell me a joke!”** — 😂 Route to **fun interaction** module  

Instead of creating a single, complex response system, **routing** ensures that each type of query is processed by the right “expert” logic.

---

## 🎯 **When to Use Routing**  
Routing is ideal when:  
✅ The task is complex with distinct categories.  
✅ Different types of inputs need specialized handling.  
✅ You want to improve accuracy by separating concerns.  

---

## 💻 **Code Walkthrough with Detailed Explanations**  

Let’s break down the provided code step by step:  

---

### 📦 **1. Import Required Libraries**  
```python
from typing_extensions import Literal
from pydantic import BaseModel, Field
from langchain_core.messages import HumanMessage, SystemMessage
```
### ✨ **Explanation:**  
- `Literal`: Specifies exact allowed values for a variable (like `"poem"`, `"story"`, `"joke"`).  
- `BaseModel`: Used to define structured data models with validation (from **Pydantic**).  
- `HumanMessage` & `SystemMessage`: Help simulate human and system conversations in LangChain.

---

### 📝 **2. Defining the Routing Schema**  
```python
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )
```
### ✨ **Explanation:**  
- **`Route` class:** Defines the valid routes (poem, story, joke).  
- The **`step`** variable will hold which task to run based on the user’s input.

---

### 🔀 **3. Setting Up the Router**  
```python
router = llm.with_structured_output(Route)
```
### ✨ **Explanation:**  
- **`router`:** Augments (adds) the LLM output to follow the `Route` schema.  
- The LLM will now output **structured data** (like `"poem"`, `"story"`, or `"joke"`) instead of just plain text.

---

### 🎨 **4. Task Functions for Each Route**  

#### ✍️ **Story Task**  
```python
@task
def llm_call_1(input_: str):
    """Write a story"""
    result = llm.invoke(input_)
    return result.content
```
#### 😂 **Joke Task**  
```python
@task
def llm_call_2(input_: str):
    """Write a joke"""
    result = llm.invoke(input_)
    return result.content
```
#### 📝 **Poem Task**  
```python
@task
def llm_call_3(input_: str):
    """Write a poem"""
    result = llm.invoke(input_)
    return result.content
```
### ✨ **Explanation:**  
- **`@task`:** Marks these functions as tasks in the workflow.  
- **`llm.invoke(input_)`:** Calls the LLM to process the input.  
- **`.content`:** Extracts the generated text (story, joke, or poem).

---

### 🛣️ **5. Routing Logic Function**  
```python
def llm_call_router(input_: str):
    """Route the input to the appropriate node"""
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=input_),
        ]
    )
    return decision.step
```
### ✨ **Explanation:**  
- The **LLM is asked** to classify the input (`input_`) into **story**, **joke**, or **poem**.  
- The **`decision.step`** will return which path to follow based on user input.

---

### 🚀 **6. The Main Workflow**  
```python
@entrypoint()
def router_workflow(input_: str):
    next_step = llm_call_router(input_)
    if next_step == "story":
        llm_call = llm_call_1
    elif next_step == "joke":
        llm_call = llm_call_2
    elif next_step == "poem":
        llm_call = llm_call_3

    return llm_call(input_).result()
```
### ✨ **Explanation:**  
- **`@entrypoint()`:** This marks the main function where the entire workflow begins.  
- **`llm_call_router(input_)`:** Decides what the next step is (story, joke, or poem).  
- Based on the result, it **calls the appropriate task function** and returns the final output.

---

### 🏃 **7. Running the Workflow**  
```python
# Invoke
for step in router_workflow.stream("Write me a joke about cats", stream_mode="updates"):
    print(step)
    print("\n")
```
### ✨ **Explanation:**  
- **`router_workflow.stream(...)`:** Starts the workflow and streams the output step by step.  
- **Output:** You’ll get a **joke about cats** because the router recognized the request as a joke.

---

## 🌈 **Example Output:**  
```
Why did the cat sit on the computer?  
Because it wanted to keep an eye on the mouse! 🐭😂
```

---

## 🌎 **Real-World Use Cases for Routing**  

1️⃣ **Customer Support Chatbots**  
   - Route complaints to customer care.  
   - Route product questions to sales.  
   - Route technical issues to tech support.  

2️⃣ **Content Generation Platforms**  
   - Generate blogs, poems, or stories based on user input.  
   - Route SEO-related tasks separately for optimization.  

3️⃣ **Healthcare Chatbots**  
   - Route emergency-related messages for urgent care.  
   - Route health advice questions to general FAQs.  
   - Route appointment booking queries to scheduling systems.  

---

## 📝 **Summary of Key Points**  
✅ **Routing** helps divide tasks by category.  
✅ It improves **accuracy** by using specialized follow-up tasks.  
✅ Works well for **complex, multi-faceted tasks**.  
✅ Can use **structured outputs** to decide routing paths.  

---

💬 **Let me know if you need more real-world scenarios or a deeper dive into any specific part!** 😊

# # Complete Code of Functional API (beta)
```python
from typing_extensions import Literal
from pydantic import BaseModel
from langchain_core.messages import HumanMessage, SystemMessage


# Schema for structured output to use as routing logic
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )


# Augment the LLM with schema for structured output
router = llm.with_structured_output(Route)


@task
def llm_call_1(input_: str):
    """Write a story"""
    result = llm.invoke(input_)
    return result.content


@task
def llm_call_2(input_: str):
    """Write a joke"""
    result = llm.invoke(input_)
    return result.content


@task
def llm_call_3(input_: str):
    """Write a poem"""
    result = llm.invoke(input_)
    return result.content


def llm_call_router(input_: str):
    """Route the input to the appropriate node"""
    # Run the augmented LLM with structured output to serve as routing logic
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=input_),
        ]
    )
    return decision.step


# Create workflow
@entrypoint()
def router_workflow(input_: str):
    next_step = llm_call_router(input_)
    if next_step == "story":
        llm_call = llm_call_1
    elif next_step == "joke":
        llm_call = llm_call_2
    elif next_step == "poem":
        llm_call = llm_call_3

    return llm_call(input_).result()

# Invoke
for step in router_workflow.stream("Write me a joke about cats", stream_mode="updates"):
    print(step)
    print("\n")

```

# Complete Code of Graph API
```python

from typing_extensions import Literal
from langchain_core.messages import HumanMessage, SystemMessage


# Schema for structured output to use as routing logic
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )


# Augment the LLM with schema for structured output
router = llm.with_structured_output(Route)


# State
class State(TypedDict):
    input: str
    decision: str
    output: str


# Nodes
def llm_call_1(state: State):
    """Write a story"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_2(state: State):
    """Write a joke"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_3(state: State):
    """Write a poem"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_router(state: State):
    """Route the input to the appropriate node"""

    # Run the augmented LLM with structured output to serve as routing logic
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=state["input"]),
        ]
    )

    return {"decision": decision.step}


# Conditional edge function to route to the appropriate node
def route_decision(state: State):
    # Return the node name you want to visit next
    if state["decision"] == "story":
        return "llm_call_1"
    elif state["decision"] == "joke":
        return "llm_call_2"
    elif state["decision"] == "poem":
        return "llm_call_3"


# Build workflow
router_builder = StateGraph(State)

# Add nodes
router_builder.add_node("llm_call_1", llm_call_1)
router_builder.add_node("llm_call_2", llm_call_2)
router_builder.add_node("llm_call_3", llm_call_3)
router_builder.add_node("llm_call_router", llm_call_router)

# Add edges to connect nodes
router_builder.add_edge(START, "llm_call_router")
router_builder.add_conditional_edges(
    "llm_call_router",
    route_decision,
    {  # Name returned by route_decision : Name of next node to visit
        "llm_call_1": "llm_call_1",
        "llm_call_2": "llm_call_2",
        "llm_call_3": "llm_call_3",
    },
)
router_builder.add_edge("llm_call_1", END)
router_builder.add_edge("llm_call_2", END)
router_builder.add_edge("llm_call_3", END)

# Compile workflow
router_workflow = router_builder.compile()

# Show the workflow
display(Image(router_workflow.get_graph().draw_mermaid_png()))

# Invoke
state = router_workflow.invoke({"input": "Write me a joke about cats"})
print(state["output"])

```

Here’s a **detailed and beginner-friendly explanation** of the **Routing** concept, complete with real-world examples, code breakdown, and easy explanations of each line of code. I'll use headings, icons, and clear explanations for better understanding.  

---

# 🌟 **Understanding Routing in LLM Workflows**  

---

## 📚 **What is Routing?**  

**Routing** in LLM (Large Language Model) workflows refers to the process of classifying an input and directing it to a specific follow-up task.  

💡 **Key Idea:** Instead of handling all inputs the same way, we **route** them based on what they are asking for. This ensures that each request is handled using the most appropriate process.  

---

### 🌍 **Real-World Example of Routing**  
Imagine you’re running a **customer service chatbot** for an online store. Users ask different questions:  
- **“What is my order status?”** — 📝 Route to **order tracking** module  
- **“I want to return an item.”** — 🔄 Route to **returns** module  
- **“Tell me a joke!”** — 😂 Route to **fun interaction** module  

Instead of creating a single, complex response system, **routing** ensures that each type of query is processed by the right “expert” logic.

---

## 🎯 **When to Use Routing**  
Routing is ideal when:  
✅ The task is complex with distinct categories.  
✅ Different types of inputs need specialized handling.  
✅ You want to improve accuracy by separating concerns.  

---

## 💻 **Code Walkthrough with Detailed Explanations**  

Let’s break down the provided code step by step:  

---

### 📦 **1. Import Required Libraries**  
```python
from typing_extensions import Literal
from pydantic import BaseModel, Field
from langchain_core.messages import HumanMessage, SystemMessage
```
### ✨ **Explanation:**  
- `Literal`: Specifies exact allowed values for a variable (like `"poem"`, `"story"`, `"joke"`).  
- `BaseModel`: Used to define structured data models with validation (from **Pydantic**).  
- `HumanMessage` & `SystemMessage`: Help simulate human and system conversations in LangChain.

---

### 📝 **2. Defining the Routing Schema**  
```python
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )
```
### ✨ **Explanation:**  
- **`Route` class:** Defines the valid routes (poem, story, joke).  
- The **`step`** variable will hold which task to run based on the user’s input.

---

### 🔀 **3. Setting Up the Router**  
```python
router = llm.with_structured_output(Route)
```
### ✨ **Explanation:**  
- **`router`:** Augments (adds) the LLM output to follow the `Route` schema.  
- The LLM will now output **structured data** (like `"poem"`, `"story"`, or `"joke"`) instead of just plain text.

---

### 🎨 **4. Task Functions for Each Route**  

#### ✍️ **Story Task**  
```python
@task
def llm_call_1(input_: str):
    """Write a story"""
    result = llm.invoke(input_)
    return result.content
```
#### 😂 **Joke Task**  
```python
@task
def llm_call_2(input_: str):
    """Write a joke"""
    result = llm.invoke(input_)
    return result.content
```
#### 📝 **Poem Task**  
```python
@task
def llm_call_3(input_: str):
    """Write a poem"""
    result = llm.invoke(input_)
    return result.content
```
### ✨ **Explanation:**  
- **`@task`:** Marks these functions as tasks in the workflow.  
- **`llm.invoke(input_)`:** Calls the LLM to process the input.  
- **`.content`:** Extracts the generated text (story, joke, or poem).

---

### 🛣️ **5. Routing Logic Function**  
```python
def llm_call_router(input_: str):
    """Route the input to the appropriate node"""
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=input_),
        ]
    )
    return decision.step
```
### ✨ **Explanation:**  
- The **LLM is asked** to classify the input (`input_`) into **story**, **joke**, or **poem**.  
- The **`decision.step`** will return which path to follow based on user input.

---

### 🚀 **6. The Main Workflow**  
```python
@entrypoint()
def router_workflow(input_: str):
    next_step = llm_call_router(input_)
    if next_step == "story":
        llm_call = llm_call_1
    elif next_step == "joke":
        llm_call = llm_call_2
    elif next_step == "poem":
        llm_call = llm_call_3

    return llm_call(input_).result()
```
### ✨ **Explanation:**  
- **`@entrypoint()`:** This marks the main function where the entire workflow begins.  
- **`llm_call_router(input_)`:** Decides what the next step is (story, joke, or poem).  
- Based on the result, it **calls the appropriate task function** and returns the final output.

---

### 🏃 **7. Running the Workflow**  
```python
# Invoke
for step in router_workflow.stream("Write me a joke about cats", stream_mode="updates"):
    print(step)
    print("\n")
```
### ✨ **Explanation:**  
- **`router_workflow.stream(...)`:** Starts the workflow and streams the output step by step.  
- **Output:** You’ll get a **joke about cats** because the router recognized the request as a joke.

---

## 🌈 **Example Output:**  
```
Why did the cat sit on the computer?  
Because it wanted to keep an eye on the mouse! 🐭😂
```

---

## 🌎 **Real-World Use Cases for Routing**  

1️⃣ **Customer Support Chatbots**  
   - Route complaints to customer care.  
   - Route product questions to sales.  
   - Route technical issues to tech support.  

2️⃣ **Content Generation Platforms**  
   - Generate blogs, poems, or stories based on user input.  
   - Route SEO-related tasks separately for optimization.  

3️⃣ **Healthcare Chatbots**  
   - Route emergency-related messages for urgent care.  
   - Route health advice questions to general FAQs.  
   - Route appointment booking queries to scheduling systems.  

---

## 📝 **Summary of Key Points**  
✅ **Routing** helps divide tasks by category.  
✅ It improves **accuracy** by using specialized follow-up tasks.  
✅ Works well for **complex, multi-faceted tasks**.  
✅ Can use **structured outputs** to decide routing paths.  

---

# o3 mini:
# 🌟 **Understanding Orchestrator-Worker Workflows**

Orchestrator-worker is a powerful pattern for breaking down complex tasks into manageable subtasks. In this setup, a central **orchestrator** LLM dynamically analyzes the task, splits it into smaller pieces, and then **delegates** each piece to specialized **worker** nodes. Finally, the orchestrator collects and synthesizes all worker outputs into a final result.

---

## 🎯 **What is Orchestrator-Worker?**

Imagine you need to write a long, detailed report. Instead of writing the whole report at once, you can:
- **Orchestrator:** Plan the report by deciding on sections (like introduction, methods, results, and conclusion).
- **Workers:** Write each section separately based on the orchestrator's plan.
- **Synthesizer:** Combine all the sections into one complete report.

This separation of duties makes it easier to handle tasks where the number and nature of subtasks depend on the specific input.

---

## 🌍 **Real-World Example**

**Scenario: Generating a Research Report on LLM Scaling Laws**

- **Orchestrator:** Reviews the topic *"LLM scaling laws"* and creates a plan with multiple sections:
  - **Introduction**
  - **Historical Background**
  - **Key Scaling Principles**
  - **Future Prospects**
- **Workers:** Each worker writes the content for one section based on the provided plan.
- **Synthesizer:** Combines these sections into a cohesive final report.

This approach is especially useful in domains like journalism, research report writing, or any project where the task is too complex to handle in one step.

---

## 💻 **Code Example & Detailed Explanation**

Below is a sample code that demonstrates an orchestrator-worker workflow using LangGraph's API. We'll break it down step by step.

---

### 1. **Imports and Schema Definitions**

```python
from typing import Annotated, List
import operator
from pydantic import BaseModel, Field
from langchain_core.messages import HumanMessage, SystemMessage
```

- **`typing` and `operator`**: Used for type annotations and list operations.
- **`BaseModel` and `Field` (Pydantic)**: Create structured data models to validate and format our data.
- **`HumanMessage` and `SystemMessage`**: Simulate conversation messages for the LLM.

---

### 2. **Defining the Report Sections Schema**

```python
class Section(BaseModel):
    name: str = Field(
        description="Name for this section of the report."
    )
    description: str = Field(
        description="Brief overview of the main topics and concepts to be covered in this section."
    )

class Sections(BaseModel):
    sections: List[Section] = Field(
        description="Sections of the report."
    )
```

- **`Section` class**: Represents a single section with a name and a description.
- **`Sections` class**: Contains a list of `Section` objects.  
- **Purpose:** Provides a structured way for the orchestrator to output a plan for the report.

---

### 3. **Setting Up the Planner**

```python
# Augment the LLM with schema for structured output (the report plan)
planner = llm.with_structured_output(Sections)
```

- **`planner`**: Enhances the LLM so it returns data conforming to our `Sections` schema.  
- **Purpose:** When the orchestrator runs, it uses this planner to generate a structured report plan.

---

### 4. **Defining the Graph State**

```python
from typing import TypedDict

class State(TypedDict):
    topic: str  # Report topic
    sections: list[Section]  # List of report sections
    completed_sections: Annotated[list, operator.add]  # All workers write to this key in parallel
    final_report: str  # Final report

class WorkerState(TypedDict):
    section: Section
    completed_sections: Annotated[list, operator.add]
```

- **`State`**: Global state for the entire workflow.
  - **`topic`**: The report topic.
  - **`sections`**: Planned sections from the orchestrator.
  - **`completed_sections`**: A shared list where worker outputs are aggregated.
  - **`final_report`**: The synthesized final report.
- **`WorkerState`**: State for each individual worker, including the specific section they will work on.

---

### 5. **The Orchestrator Node**

```python
def orchestrator(state: State):
    """Orchestrator that generates a plan for the report"""
    # Generate report sections using the planner LLM
    report_sections = planner.invoke(
        [
            SystemMessage(content="Generate a plan for the report."),
            HumanMessage(content=f"Here is the report topic: {state['topic']}")
        ]
    )
    return {"sections": report_sections.sections}
```

- **What it does:**
  - The orchestrator uses the LLM to generate a report plan based on the given topic.
  - **`planner.invoke(...)`**: Sends a system message and the human-provided topic to generate the sections.
- **Return Value:** A dictionary containing the list of planned sections.

---

### 6. **The Worker Node**

```python
def llm_call(state: WorkerState):
    """Worker writes a section of the report"""
    section = llm.invoke(
        [
            SystemMessage(
                content="Write a report section following the provided name and description. Include no preamble for each section. Use markdown formatting."
            ),
            HumanMessage(
                content=f"Here is the section name: {state['section'].name} and description: {state['section'].description}"
            )
        ]
    )
    # Write the updated section content to completed sections
    return {"completed_sections": [section.content]}
```

- **What it does:**
  - Each worker writes a specific section using the LLM.
  - The prompt instructs the LLM to write in markdown without extra preamble.
- **Return Value:** A dictionary with the worker's output stored in `completed_sections`.

---

### 7. **The Synthesizer Node**

```python
def synthesizer(state: State):
    """Synthesize full report from sections"""
    completed_sections = state["completed_sections"]
    completed_report_sections = "\n\n---\n\n".join(completed_sections)
    return {"final_report": completed_report_sections}
```

- **What it does:**
  - Collects all completed sections from the workers.
  - Joins them together using markdown formatting (with `---` as a separator).
- **Return Value:** The final complete report.

---

### 8. **Assigning Workers Using the Send API**

```python
from langgraph.constants import Send

def assign_workers(state: State):
    """Assign a worker to each section in the plan"""
    # Kick off section writing in parallel via Send() API
    return [Send("llm_call", {"section": s}) for s in state["sections"]]
```

- **Purpose:**
  - This function dynamically assigns each section from the orchestrator’s plan to a separate worker.
  - **`Send("llm_call", {"section": s})`**: Creates a task for each section.
- **Outcome:** Workers will process their assigned section in parallel, and their outputs will be collected in the shared state.

---

### 9. **Building and Compiling the Workflow**

```python
# Build workflow
orchestrator_worker_builder = StateGraph(State)

# Add nodes (tasks)
orchestrator_worker_builder.add_node("orchestrator", orchestrator)
orchestrator_worker_builder.add_node("llm_call", llm_call)
orchestrator_worker_builder.add_node("synthesizer", synthesizer)

# Define the edges (flow)
orchestrator_worker_builder.add_edge(START, "orchestrator")
orchestrator_worker_builder.add_conditional_edges("orchestrator", assign_workers, ["llm_call"])
orchestrator_worker_builder.add_edge("llm_call", "synthesizer")
orchestrator_worker_builder.add_edge("synthesizer", END)

# Compile the workflow
orchestrator_worker = orchestrator_worker_builder.compile()
```

- **Purpose:**
  - **`StateGraph(State)`**: Initializes the workflow with our defined global state.
  - **Nodes and Edges:** Define the flow from orchestrator to workers and finally to synthesizer.
  - **`add_conditional_edges`**: Dynamically creates worker tasks based on the orchestrator's output.
- **Compilation:** Produces a runnable workflow graph.

---

### 10. **Visualizing and Running the Workflow**

```python
# Display the workflow graph
display(Image(orchestrator_worker.get_graph().draw_mermaid_png()))

# Invoke the workflow with a topic
state = orchestrator_worker.invoke({"topic": "Create a report on LLM scaling laws"})

# Display the final report (formatted in markdown)
from IPython.display import Markdown
Markdown(state["final_report"])
```

- **What it does:**
  - **Visualization:** Uses Mermaid (a diagramming tool) to show the workflow structure.
  - **Invocation:** Runs the workflow with a given report topic.
  - **Output:** Displays the final synthesized report in a readable markdown format.

---

## 🏆 **Key Takeaways**

- **Orchestrator-Worker Workflow** splits a complex task into dynamically determined subtasks.
- **Orchestrator:** Plans the task (e.g., creating sections for a report).
- **Workers:** Execute the individual parts concurrently.
- **Synthesizer:** Combines all worker outputs into a final, cohesive result.
- **Real-World Uses:**  
  - **Report Generation:** Research reports, market analyses, or technical documentation.  
  - **Project Management:** Breaking down a project into milestones and tasks.  
  - **Content Creation:** Creating comprehensive guides or multi-part articles.

---

💬 **Final Thoughts:**  
The orchestrator-worker model is highly flexible and efficient for tackling complex problems where subtasks are not predetermined but need to be generated on the fly. It’s a robust pattern that can be applied in many fields such as research, content creation, and project management.

Feel free to ask if you need more examples or further clarifications on any part of this workflow!

---
💬 **Let me know if you need more real-world scenarios or a deeper dive into any specific part!** 😊


# # Complete Code of Functional API (beta)
```python
from typing_extensions import Literal
from pydantic import BaseModel
from langchain_core.messages import HumanMessage, SystemMessage


# Schema for structured output to use as routing logic
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )


# Augment the LLM with schema for structured output
router = llm.with_structured_output(Route)


@task
def llm_call_1(input_: str):
    """Write a story"""
    result = llm.invoke(input_)
    return result.content


@task
def llm_call_2(input_: str):
    """Write a joke"""
    result = llm.invoke(input_)
    return result.content


@task
def llm_call_3(input_: str):
    """Write a poem"""
    result = llm.invoke(input_)
    return result.content


def llm_call_router(input_: str):
    """Route the input to the appropriate node"""
    # Run the augmented LLM with structured output to serve as routing logic
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=input_),
        ]
    )
    return decision.step


# Create workflow
@entrypoint()
def router_workflow(input_: str):
    next_step = llm_call_router(input_)
    if next_step == "story":
        llm_call = llm_call_1
    elif next_step == "joke":
        llm_call = llm_call_2
    elif next_step == "poem":
        llm_call = llm_call_3

    return llm_call(input_).result()

# Invoke
for step in router_workflow.stream("Write me a joke about cats", stream_mode="updates"):
    print(step)
    print("\n")

```

# Complete Code of Graph API
```python

from typing_extensions import Literal
from langchain_core.messages import HumanMessage, SystemMessage


# Schema for structured output to use as routing logic
class Route(BaseModel):
    step: Literal["poem", "story", "joke"] = Field(
        None, description="The next step in the routing process"
    )


# Augment the LLM with schema for structured output
router = llm.with_structured_output(Route)


# State
class State(TypedDict):
    input: str
    decision: str
    output: str


# Nodes
def llm_call_1(state: State):
    """Write a story"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_2(state: State):
    """Write a joke"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_3(state: State):
    """Write a poem"""

    result = llm.invoke(state["input"])
    return {"output": result.content}


def llm_call_router(state: State):
    """Route the input to the appropriate node"""

    # Run the augmented LLM with structured output to serve as routing logic
    decision = router.invoke(
        [
            SystemMessage(
                content="Route the input to story, joke, or poem based on the user's request."
            ),
            HumanMessage(content=state["input"]),
        ]
    )

    return {"decision": decision.step}


# Conditional edge function to route to the appropriate node
def route_decision(state: State):
    # Return the node name you want to visit next
    if state["decision"] == "story":
        return "llm_call_1"
    elif state["decision"] == "joke":
        return "llm_call_2"
    elif state["decision"] == "poem":
        return "llm_call_3"


# Build workflow
router_builder = StateGraph(State)

# Add nodes
router_builder.add_node("llm_call_1", llm_call_1)
router_builder.add_node("llm_call_2", llm_call_2)
router_builder.add_node("llm_call_3", llm_call_3)
router_builder.add_node("llm_call_router", llm_call_router)

# Add edges to connect nodes
router_builder.add_edge(START, "llm_call_router")
router_builder.add_conditional_edges(
    "llm_call_router",
    route_decision,
    {  # Name returned by route_decision : Name of next node to visit
        "llm_call_1": "llm_call_1",
        "llm_call_2": "llm_call_2",
        "llm_call_3": "llm_call_3",
    },
)
router_builder.add_edge("llm_call_1", END)
router_builder.add_edge("llm_call_2", END)
router_builder.add_edge("llm_call_3", END)

# Compile workflow
router_workflow = router_builder.compile()

# Show the workflow
display(Image(router_workflow.get_graph().draw_mermaid_png()))

# Invoke
state = router_workflow.invoke({"input": "Write me a joke about cats"})
print(state["output"])

```

# 🌟 **Evaluator-Optimizer Workflow Explained**  

The **Evaluator-Optimizer** workflow is a powerful pattern in AI systems that allows iterative improvement of results. In this guide, we will explain the concept step by step, show real-world applications, provide code examples, and explain each line of the code.

---

## 💡 **What is the Evaluator-Optimizer Workflow?**  

In this workflow:  
1. **Generator**: A model generates an initial response based on input.  
2. **Evaluator**: Another model evaluates the generated response, gives feedback, and suggests improvements.  
3. **Loop**: This process continues until the output meets predefined criteria.

---

## 📚 **When to Use Evaluator-Optimizer Workflow?**  
This workflow is useful when:  
- You have **clear evaluation criteria** (e.g., correctness, humor, relevance).  
- **Iterative improvement** adds value (e.g., improving jokes, refining answers, or enhancing designs).  
- **Feedback can be provided** by the model itself or a human.

---

## 🌎 **Real-World Applications**  
- ✅ **Content Creation**: Refining blog posts, jokes, or stories.  
- 🎬 **Script Writing**: Polishing movie scripts with iterative feedback.  
- 📝 **Essay Grading**: Providing feedback for students to improve essays.  
- 💬 **Chatbots**: Enhancing chatbot responses for better customer service.

---

## 🛠 **Code Example (with Detailed Explanation)**  

Let's break down a Python example using LangChain's `Evaluator-Optimizer` concept.

---

### 🔄 **Step 1: Define Feedback Schema**  
This ensures the feedback from the evaluator is structured.

```python
from pydantic import BaseModel, Field
from typing import Literal

# Schema for feedback
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not."
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it."
    )
```
### 📝 **Explanation**  
- `BaseModel`: Defines the structure of our feedback using Pydantic.  
- `grade`: The evaluator will classify the joke as **funny** or **not funny**.  
- `feedback`: If the joke isn’t funny, suggestions for improvement will be provided.

---

### 🔄 **Step 2: Augment LLM with Feedback Schema**  

```python
evaluator = llm.with_structured_output(Feedback)
```
### 📝 **Explanation**  
- `with_structured_output(Feedback)`: Ensures the output matches the `Feedback` structure defined earlier.

---

### ⚡ **Step 3: Generate Jokes with Feedback Consideration**  

```python
@task
def llm_call_generator(topic: str, feedback: Feedback):
    """LLM generates a joke"""
    if feedback:
        msg = llm.invoke(
            f"Write a joke about {topic} but take into account the feedback: {feedback}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content
```
### 📝 **Explanation**  
- **Purpose**: To generate a joke based on the topic.  
- **Logic**:  
  - If there’s feedback, generate a joke with the feedback considered.  
  - If not, just generate a basic joke.

---

### 🔍 **Step 4: Evaluate the Joke**  

```python
@task
def llm_call_evaluator(joke: str):
    """LLM evaluates the joke"""
    feedback = evaluator.invoke(f"Grade the joke {joke}")
    return feedback
```
### 📝 **Explanation**  
- The evaluator grades the joke and provides feedback if it’s not funny.

---

### 🔄 **Step 5: Optimizer Loop**  

```python
@entrypoint()
def optimizer_workflow(topic: str):
    feedback = None
    while True:
        joke = llm_call_generator(topic, feedback).result()
        feedback = llm_call_evaluator(joke).result()
        if feedback.grade == "funny":
            break
    return joke
```
### 📝 **Explanation**  
- **feedback = None**: Initially, there’s no feedback.  
- **while True**: The loop runs until the joke is "funny."  
- **llm_call_generator**: Generates a joke with feedback.  
- **llm_call_evaluator**: Evaluates the joke.  
- **break**: Ends the loop if the joke is funny.

---

### 🚀 **Step 6: Running the Workflow**  

```python
# Invoke
for step in optimizer_workflow.stream("Cats", stream_mode="updates"):
    print(step)
    print("\n")
```
### 📝 **Explanation**  
- **optimizer_workflow.stream("Cats")**: Starts the workflow with "Cats" as the topic.  
- **stream_mode="updates"**: Prints progress at each iteration.

---

## 🎉 **Output Example:**  
```
First attempt joke: "Why don’t cats play poker in the jungle? Too many cheetahs."  
Evaluator feedback: "Not funny—too common. Try something unique."  

Second attempt joke: "What do you call a pile of kittens? A meowtain."  
Evaluator feedback: "Funnier but could be wittier."  

Third attempt joke: "Why did the cat get a job? Because it wanted to be purr-suasive in sales!"  
Evaluator feedback: "Funny."  
```

---

## 🌟 **Key Takeaways**  
- **Iterative Process**: The generator and evaluator work together until the best result is achieved.  
- **Flexible Applications**: Can be used for various creative and technical tasks.  
- **Clear Criteria**: Essential for evaluating outputs effectively.  

---

💬 *Let me know if you’d like more advanced scenarios or deeper insights into LangChain integrations!*



# Code of Functional API (beta)
```python
# Schema for structured output to use in evaluation
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not.",
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it.",
    )


# Augment the LLM with schema for structured output
evaluator = llm.with_structured_output(Feedback)


# Nodes
@task
def llm_call_generator(topic: str, feedback: Feedback):
    """LLM generates a joke"""
    if feedback:
        msg = llm.invoke(
            f"Write a joke about {topic} but take into account the feedback: {feedback}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content


@task
def llm_call_evaluator(joke: str):
    """LLM evaluates the joke"""
    feedback = evaluator.invoke(f"Grade the joke {joke}")
    return feedback


@entrypoint()
def optimizer_workflow(topic: str):
    feedback = None
    while True:
        joke = llm_call_generator(topic, feedback).result()
        feedback = llm_call_evaluator(joke).result()
        if feedback.grade == "funny":
            break

    return joke

# Invoke
for step in optimizer_workflow.stream("Cats", stream_mode="updates"):
    print(step)
    print("\n")

```

# Complete Code of Graph API
```python
# Graph state
class State(TypedDict):
    joke: str
    topic: str
    feedback: str
    funny_or_not: str


# Schema for structured output to use in evaluation
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not.",
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it.",
    )


# Augment the LLM with schema for structured output
evaluator = llm.with_structured_output(Feedback)


# Nodes
def llm_call_generator(state: State):
    """LLM generates a joke"""

    if state.get("feedback"):
        msg = llm.invoke(
            f"Write a joke about {state['topic']} but take into account the feedback: {state['feedback']}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {state['topic']}")
    return {"joke": msg.content}


def llm_call_evaluator(state: State):
    """LLM evaluates the joke"""

    grade = evaluator.invoke(f"Grade the joke {state['joke']}")
    return {"funny_or_not": grade.grade, "feedback": grade.feedback}


# Conditional edge function to route back to joke generator or end based upon feedback from the evaluator
def route_joke(state: State):
    """Route back to joke generator or end based upon feedback from the evaluator"""

    if state["funny_or_not"] == "funny":
        return "Accepted"
    elif state["funny_or_not"] == "not funny":
        return "Rejected + Feedback"


# Build workflow
optimizer_builder = StateGraph(State)

# Add the nodes
optimizer_builder.add_node("llm_call_generator", llm_call_generator)
optimizer_builder.add_node("llm_call_evaluator", llm_call_evaluator)

# Add edges to connect nodes
optimizer_builder.add_edge(START, "llm_call_generator")
optimizer_builder.add_edge("llm_call_generator", "llm_call_evaluator")
optimizer_builder.add_conditional_edges(
    "llm_call_evaluator",
    route_joke,
    {  # Name returned by route_joke : Name of next node to visit
        "Accepted": END,
        "Rejected + Feedback": "llm_call_generator",
    },
)

# Compile the workflow
optimizer_workflow = optimizer_builder.compile()

# Show the workflow
display(Image(optimizer_workflow.get_graph().draw_mermaid_png()))

# Invoke
state = optimizer_workflow.invoke({"topic": "Cats"})
print(state["joke"])

```


# 🤖 **Understanding Agents in LangChain**

Agents in LangChain allow AI models to perform complex tasks by interacting with tools in a loop based on feedback. Let’s break down this concept step by step.

---

# 🌟 **What Are Agents?**

An **Agent** is like a smart assistant that:
- Uses **tools** to complete tasks.
- Makes decisions based on **feedback** from its environment.
- Works in a **loop** until the desired outcome is achieved.

### 💡 **Key Points:**
- Agents handle **complex tasks** that require multiple steps.
- They are **autonomous**, meaning they decide which tools to use.
- The loop continues until the task is completed correctly.

### 🎯 **Real-Life Example:**
Imagine a personal assistant who:
1. Checks your calendar (tool 1).
2. Books a flight (tool 2).
3. Orders a cab (tool 3).

The assistant will:
- Check if each step was successful.
- Move to the next step or fix issues if needed.

---

# 🕒 **When Should You Use Agents?**

Agents are best for:

✅ **Open-ended tasks**: Problems where the number of steps isn’t fixed.  
✅ **Complex decision-making**: Tasks that need logical decisions at each step.  
✅ **Autonomous workflows**: When you want the AI to work with minimal supervision.

### 📝 **Example Use Cases:**
- Automated customer support.
- Data processing pipelines.
- Personalized shopping assistants.

---

# 🛠 **Tools in Agents**

Agents rely on **tools** to perform specific actions. Let’s define some simple tools.

### ⚙️ **Step 1: Defining Tools**
```python
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

@tool
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

@tool
def divide(a: int, b: int) -> float:
    """Divide two numbers."""
    return a / b
```

### 🔍 **Explanation:**
- Each function performs a basic arithmetic operation.
- The `@tool` decorator tells LangChain that these functions are available for the agent to use.

---

# 🔗 **Connecting Tools to the Agent**

Now, let’s bind these tools to our language model (LLM).

```python
# Augment the LLM with tools
tools = [add, multiply, divide]
tools_by_name = {tool.name: tool for tool in tools}
llm_with_tools = llm.bind_tools(tools)
```

### 💬 **Explanation:**
- We create a list of tools.
- Use a dictionary (`tools_by_name`) for quick access.
- **Bind** these tools to the LLM so it can use them during execution.

---

# 🤔 **How the Agent Works (Step by Step)**

### ⚡ **Step 2: LLM Decides Which Tool to Use**
```python
from langchain_core.messages import SystemMessage, HumanMessage, BaseMessage, ToolCall

@task
def call_llm(messages: list[BaseMessage]):
    """LLM decides whether to call a tool or not."""
    return llm_with_tools.invoke(
        [SystemMessage(content="You are a helpful assistant performing arithmetic tasks.")] + messages
    )
```

### 💬 **Explanation:**
- The LLM receives a system instruction and user messages.
- Based on these messages, it decides which tool to call.

### 🛠 **Step 3: Performing the Tool Call**
```python
@task
def call_tool(tool_call: ToolCall):
    """Performs the tool call."""
    tool = tools_by_name[tool_call["name"]]
    return tool.invoke(tool_call)
```

### 💬 **Explanation:**
- The chosen tool is executed with the given parameters.

---

# 🔄 **Step 4: The Agent Loop**

This loop continues until the LLM no longer needs to call a tool.

```python
@entrypoint()
def agent(messages: list[BaseMessage]):
    llm_response = call_llm(messages).result()

    while True:
        if not llm_response.tool_calls:
            break  # Exit loop if no more tools are needed

        # Execute tools
        tool_result_futures = [call_tool(tool_call) for tool_call in llm_response.tool_calls]
        tool_results = [fut.result() for fut in tool_result_futures]
        messages = add_messages(messages, [llm_response, *tool_results])
        llm_response = call_llm(messages).result()

    messages = add_messages(messages, llm_response)
    return messages
```

### 💬 **Explanation:**
- The **while loop** checks if the LLM wants to call a tool.
- It **executes** the tool and **updates** the messages.
- The loop **ends** when no more tools are required.

---

# 🚀 **Step 5: Running the Agent**

Let’s see the agent in action with a simple arithmetic task.

```python
# Invoke the agent
messages = [HumanMessage(content="Add 3 and 4.")]
for chunk in agent.stream(messages, stream_mode="updates"):
    print(chunk)
    print("\n")
```

### 🎉 **Output:**
```
Human: Add 3 and 4.
Agent: Using add tool...
Tool output: 7
Final Answer: 7
```

---

# 🌈 **Real-World Applications of Agents**

### 🏦 **1. Financial Calculators**
- Agents can calculate loans, interests, and budgets based on user inputs.

### 🤖 **2. Customer Support Bots**
- Handling user queries by accessing different databases and tools.

### 🚀 **3. Automated Data Pipelines**
- Cleaning, processing, and analyzing data step by step.

### 🎮 **4. Game AI**
- Making decisions based on player actions and game state.

---

# 🌟 **Key Takeaways**

✅ Agents perform complex, multi-step tasks by interacting with tools.  
✅ The **feedback loop** allows them to adapt their approach.  
✅ Suitable for open-ended, dynamic tasks requiring decision-making.  

💬 *Let me know if you’d like more advanced scenarios or integrations explained further!*





```python
from langchain_core.tools import tool


# Define tools
@tool
def multiply(a: int, b: int) -> int:
    """Multiply a and b.

    Args:
        a: first int
        b: second int
    """
    return a * b


@tool
def add(a: int, b: int) -> int:
    """Adds a and b.

    Args:
        a: first int
        b: second int
    """
    return a + b


@tool
def divide(a: int, b: int) -> float:
    """Divide a and b.

    Args:
        a: first int
        b: second int
    """
    return a / b


# Augment the LLM with tools
tools = [add, multiply, divide]
tools_by_name = {tool.name: tool for tool in tools}
llm_with_tools = llm.bind_tools(tools)

```


# Complete Code of Functional API (beta)
I
```python
from langgraph.graph import add_messages
from langchain_core.messages import (
    SystemMessage,
    HumanMessage,
    BaseMessage,
    ToolCall,
)


@task
def call_llm(messages: list[BaseMessage]):
    """LLM decides whether to call a tool or not"""
    return llm_with_tools.invoke(
        [
            SystemMessage(
                content="You are a helpful assistant tasked with performing arithmetic on a set of inputs."
            )
        ]
        + messages
    )


@task
def call_tool(tool_call: ToolCall):
    """Performs the tool call"""
    tool = tools_by_name[tool_call["name"]]
    return tool.invoke(tool_call)


@entrypoint()
def agent(messages: list[BaseMessage]):
    llm_response = call_llm(messages).result()

    while True:
        if not llm_response.tool_calls:
            break

        # Execute tools
        tool_result_futures = [
            call_tool(tool_call) for tool_call in llm_response.tool_calls
        ]
        tool_results = [fut.result() for fut in tool_result_futures]
        messages = add_messages(messages, [llm_response, *tool_results])
        llm_response = call_llm(messages).result()

    messages = add_messages(messages, llm_response)
    return messages

# Invoke
messages = [HumanMessage(content="Add 3 and 4.")]
for chunk in agent.stream(messages, stream_mode="updates"):
    print(chunk)
    print("\n")

```


# Complete Code of Graph AP
```python

from langgraph.graph import MessagesState
from langchain_core.messages import SystemMessage, HumanMessage, ToolMessage


# Nodes
def llm_call(state: MessagesState):
    """LLM decides whether to call a tool or not"""

    return {
        "messages": [
            llm_with_tools.invoke(
                [
                    SystemMessage(
                        content="You are a helpful assistant tasked with performing arithmetic on a set of inputs."
                    )
                ]
                + state["messages"]
            )
        ]
    }


def tool_node(state: dict):
    """Performs the tool call"""

    result = []
    for tool_call in state["messages"][-1].tool_calls:
        tool = tools_by_name[tool_call["name"]]
        observation = tool.invoke(tool_call["args"])
        result.append(ToolMessage(content=observation, tool_call_id=tool_call["id"]))
    return {"messages": result}


# Conditional edge function to route to the tool node or end based upon whether the LLM made a tool call
def should_continue(state: MessagesState) -> Literal["environment", END]:
    """Decide if we should continue the loop or stop based upon whether the LLM made a tool call"""

    messages = state["messages"]
    last_message = messages[-1]
    # If the LLM makes a tool call, then perform an action
    if last_message.tool_calls:
        return "Action"
    # Otherwise, we stop (reply to the user)
    return END


# Build workflow
agent_builder = StateGraph(MessagesState)

# Add nodes
agent_builder.add_node("llm_call", llm_call)
agent_builder.add_node("environment", tool_node)

# Add edges to connect nodes
agent_builder.add_edge(START, "llm_call")
agent_builder.add_conditional_edges(
    "llm_call",
    should_continue,
    {
        # Name returned by should_continue : Name of next node to visit
        "Action": "environment",
        END: END,
    },
)
agent_builder.add_edge("environment", "llm_call")

# Compile the agent
agent = agent_builder.compile()

# Show the agent
display(Image(agent.get_graph(xray=True).draw_mermaid_png()))

# Invoke
messages = [HumanMessage(content="Add 3 and 4.")]
messages = agent.invoke({"messages": messages})
for m in messages["messages"]:
    m.pretty_print()

```

## 🛠️ Understanding Pre-Built Agents and Persistence in LangGraph

LangGraph provides **pre-built agents** and **persistence** mechanisms that help in managing workflows efficiently. This concept is particularly useful when building AI agents that require **long-term memory, human interaction, or streaming responses**.

---

# 🧠 What Are Pre-Built Agents?

### 🔹 **Pre-Built Agents in LangGraph**
LangGraph provides a ready-to-use method for creating an agent using the `create_react_agent` function. This simplifies the process of making **LLM-powered agents** that can call tools, process information, and generate responses dynamically.

Instead of manually defining the agent workflow, we can **use pre-built functions** to set up an agent quickly.

---

# 💡 When to Use Pre-Built Agents?

- ✅ When you need an **AI agent** that can perform **multiple tasks** dynamically.
- ✅ When you **don’t want to manually define the logic** for calling tools and making decisions.
- ✅ When your agent needs **long-term memory** to retain past conversations.
- ✅ When you need **streaming capabilities** to process large conversations in real-time.

🔹 **Real-World Example**  
Imagine building a **customer support chatbot** that can answer queries, fetch order details, and escalate complaints. Instead of manually coding all possible actions, you can use **LangGraph's pre-built agent** to handle these tasks dynamically.

---

# 🛠️ How to Use Pre-Built Agents in LangGraph?

Let's break down the code step by step.

### 🔹 **1. Import Pre-Built Agent**
```python
from langgraph.prebuilt import create_react_agent
```
👉 This imports the `create_react_agent` function from LangGraph’s pre-built module.

---

### 🔹 **2. Create the Agent**
```python
pre_built_agent = create_react_agent(llm, tools=tools)
```
✅ Here, we are **passing two things** to `create_react_agent`:
1. `llm` → The **language model** that will generate responses.
2. `tools` → A list of **tools** (functions) that the agent can call.

Example tools could be:
- **Mathematical operations** (addition, multiplication)
- **Fetching real-time weather**
- **Searching databases**

---

### 🔹 **3. Visualize the Agent’s Workflow**
```python
from IPython.display import display, Image

display(Image(pre_built_agent.get_graph().draw_mermaid_png()))
```
👉 This **displays a graphical representation** of the agent's workflow using Mermaid diagrams.

---

### 🔹 **4. Invoke the Agent**
```python
messages = [HumanMessage(content="Add 3 and 4.")]
messages = pre_built_agent.invoke({"messages": messages})
for m in messages["messages"]:
    m.pretty_print()
```
✅ This initializes a conversation with the agent:
1. **User asks a question:** `"Add 3 and 4."`
2. **Agent processes it** using the available tools.
3. **Agent returns a response** and prints it.

---

# 🛠️ What LangGraph Provides?

LangGraph is more than just a framework for AI agents. It provides **powerful features** like **persistence** and **streaming** to improve performance and reliability.

---

## 🔄 **1. Persistence: Human-in-the-Loop**
✅ **What is it?**  
The agent **pauses** execution and waits for **human approval** before proceeding.  

✅ **Example Use Case:**  
- In **medical AI**, a doctor might want to review the AI's diagnosis before confirming.
- In **financial applications**, human approval is needed for large transactions.

🔹 **LangGraph supports interruption and approval of actions, making AI more trustworthy.**

---

## 🧠 **2. Persistence: Memory (Short-Term & Long-Term)**
✅ **What is it?**  
Agents can remember previous interactions using **short-term** or **long-term memory**.

✅ **Example Use Case:**  
- A **virtual assistant** remembering past conversations.
- A **personalized shopping bot** recalling your preferences.

🔹 **LangGraph enables memory storage to improve AI interactions over time.**

---

## 🔄 **3. Streaming Responses**
✅ **What is it?**  
LangGraph allows **streaming** responses instead of waiting for full completion.

✅ **Example Use Case:**  
- A **real-time chatbot** that gives immediate partial responses.
- A **code assistant** that suggests completions while typing.

🔹 **LangGraph provides ways to stream workflow/agent outputs efficiently.**

---

# 🎯 **Conclusion**
- **Pre-built agents** simplify AI workflows by handling decision-making automatically.
- **LangGraph provides persistence, memory, and streaming** to enhance AI capabilities.
- **Real-world applications** include chatbots, virtual assistants, and automation tools.

Let me know if you need a deeper explanation of any part! 🚀