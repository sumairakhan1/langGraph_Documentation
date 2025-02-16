# 🧠 Human-in-the-Loop in LangGraph  

## 📌 Introduction  
A **Human-in-the-Loop (HITL)** workflow integrates human decisions into automated processes, allowing for validation, correction, or approval. This is crucial in AI-driven applications, especially those using **Large Language Models (LLMs)**, where occasional inaccuracies may arise.  

### 🚀 Why Use Human-in-the-Loop?  
1. **Ensures Accuracy** – Humans can validate AI-generated outputs.  
2. **Adds Context** – Users can provide additional details that AI might miss.  
3. **Improves Decision-Making** – AI can generate recommendations, but final decisions can be left to humans.  
4. **Handles Low-Error-Tolerance Scenarios** – Used in compliance, finance, and legal fields where mistakes can have serious consequences.  

---

## 📌 Real-World Use Cases of Human-in-the-Loop  

### 🛠️ **1. Reviewing Tool Calls**  
Before executing AI-generated tool requests, a human verifies and edits them.  
🔹 **Example**: AI suggests API calls for data processing, but a human reviews them before execution.  

### ✅ **2. Validating AI Outputs**  
Users review AI-generated content before it is published.  
🔹 **Example**: AI writes an article draft, but an editor finalizes it before publishing.  

### 💡 **3. Providing Context**  
AI asks humans for clarification when needed.  
🔹 **Example**: A chatbot interacts with users, but asks for human help if it struggles with user queries.  

---

## 🛠️ **Using `interrupt` in LangGraph**  

The **`interrupt` function** in LangGraph is designed to pause an AI workflow, wait for human input, and then resume processing.  

### 🔹 **Why use `interrupt`?**  
- **Pauses AI processing** to allow human review.  
- **Waits for human input** (such as corrections or approvals).  
- **Resumes execution** with updated input.  

---

## 🔍 **Code Implementation**  

Let's walk through a **step-by-step example** to understand how `interrupt` works in LangGraph.  

### 📌 **Step 1: Import Required Modules**  
```python
from langgraph.types import interrupt
```
🔹 This imports the `interrupt` function, which allows us to pause execution for human intervention.  

---

### 📌 **Step 2: Define a Human-in-the-Loop Node**  
```python
def human_node(state: dict):
    value = interrupt(
        {
            "text_to_revise": state["some_text"]
        }
    )
    return {
        "some_text": value
    }
```
🔍 **Explanation:**  
✅ **`state`** – A dictionary that holds the current AI workflow state.  
✅ **`interrupt({...})`** – Pauses execution and waits for human input.  
✅ **Returns updated `state`** – Once human input is received, the workflow continues with the new text.  

---

### 📌 **Step 3: Define & Compile the Graph**  
```python
graph = graph_builder.compile(
    checkpointer=checkpointer # Required for `interrupt` to work
)
```
🔍 **Explanation:**  
✅ **`graph_builder.compile(...)`** – Creates the AI workflow graph.  
✅ **`checkpointer`** – Saves the graph’s progress to ensure proper resumption after interruptions.  

---

### 📌 **Step 4: Run the Workflow Until `interrupt` is Triggered**  
```python
thread_config = {"configurable": {"thread_id": "some_id"}}
graph.invoke(some_input, config=thread_config)
```
🔍 **Explanation:**  
✅ **`graph.invoke(...)`** – Runs the AI workflow until `interrupt` pauses execution.  
✅ **`thread_id`** – Ensures each execution session is uniquely tracked.  

---

### 📌 **Step 5: Resume Execution with Human Input**  
```python
graph.invoke(Command(resume=value_from_human), config=thread_config)
```
🔍 **Explanation:**  
✅ **`Command(resume=value_from_human)`** – Resumes the AI workflow with the human-provided input.  
✅ **`config=thread_config`** – Maintains the session ID for tracking.  

---

## 🛠️ **Alternative Examples for Better Understanding**  

### 🔹 **Example 1: AI Content Moderation**  
AI generates a social media post, but a moderator reviews it before publishing.  
```python
def review_content(state: dict):
    review = interrupt({"post_text": state["generated_text"]})
    return {"approved_text": review}
```
✅ **Use Case**: Content moderation for blogs, ads, and news.  

---

### 🔹 **Example 2: AI-Powered Customer Support**  
A chatbot assists users but asks human agents for help if uncertain.  
```python
def support_agent_assist(state: dict):
    agent_reply = interrupt({"question": state["customer_query"]})
    return {"final_response": agent_reply}
```
✅ **Use Case**: E-commerce and help desk automation.  

---

### 🔹 **Example 3: AI-Based Legal Document Review**  
AI drafts legal contracts, but a lawyer must approve them before finalization.  
```python
def legal_review(state: dict):
    lawyer_input = interrupt({"contract_draft": state["draft_text"]})
    return {"final_contract": lawyer_input}
```
✅ **Use Case**: Legal compliance in corporate agreements.  

---

## ⚠️ **Key Considerations & Warnings**  
🚨 **Interrupts are powerful, but they do NOT automatically resume execution.**  
- The workflow **re-executes the node** instead of continuing from the exact paused point.  
- Best practice: **Place interrupts at the start of a node** or in **a dedicated node**.  

---

## 📌 **Final Thoughts**  
Human-in-the-Loop workflows in LangGraph provide a **powerful mechanism for integrating human judgment** into AI processes. By using `interrupt`, developers can build more **reliable, accurate, and context-aware AI applications.**  

💡 **Key Takeaways:**  
✅ HITL improves AI reliability.  
✅ The `interrupt` function pauses execution for human input.  
✅ Ideal for compliance, customer support, and legal review.  
✅ `interrupt` does NOT resume from the exact pause point—plan workflow design accordingly.  

🔗 **Next Steps:**  
- **Read the [official LangGraph documentation](https://langgraph.com/docs)**  
- **Experiment with different interrupt-based workflows**  
- **Implement HITL in real-world AI applications**  

🚀 **Start Building Smarter AI Applications Today!**

---

## 🧠 **Understanding Human-in-the-Loop Workflows in LangGraph**
---
### 🔍 **What is Human-in-the-Loop (HITL)?**
A **Human-in-the-Loop (HITL)** workflow is an approach that integrates **human intervention** in an otherwise automated process. This ensures that critical decisions, validations, or corrections are made at specific stages.  

It is particularly useful in **LLM-based applications**, where AI models may produce **inaccuracies or uncertain outputs**. Human involvement helps to **validate and refine** these outputs, ensuring greater reliability.

### 🚀 **Real-World Use Cases of Human-in-the-Loop**
1. **🛠️ Reviewing Tool Calls**  
   - Before an AI system executes an external **API call** (e.g., sending an email, making a transaction), a human can review and approve or reject it.
   
2. **✅ Validating AI Outputs**  
   - AI-generated **summaries, reports, or recommendations** can be reviewed by humans to ensure accuracy.
   
3. **💡 Providing Context**  
   - AI can **explicitly ask** for human input when additional details are needed in **multi-turn conversations**.

---
## 🛠️ **How to Implement Human-in-the-Loop Using `interrupt` in LangGraph**
### 🔗 **What is `interrupt` in LangGraph?**
The `interrupt` function allows **pausing an AI workflow**, presenting information to a human, and **resuming the process** with human feedback.

---
## 📌 **Design Patterns in Human-in-the-Loop Workflows**
There are three main patterns used in **HITL workflows**:

### ✅ **1. Approve or Reject an Action**
💡 **Scenario:** Suppose an AI recommends an action (e.g., approving a transaction). A human reviewer **approves** or **rejects** the action.

📌 **Steps:**
1. AI suggests an action.
2. The graph **pauses** for human approval.
3. Based on input, the workflow **proceeds** or **takes an alternate path**.

### **💻 Code Example: Approve or Reject an AI Decision**
```python
from typing import Literal
from langgraph.types import interrupt, Command

def human_approval(state):
    # Pause and ask human for approval
    is_approved = interrupt(
        {
            "question": "Is this correct?",
            "llm_output": state["llm_output"]
        }
    )

    # If approved, continue; otherwise, go to an alternate path
    if is_approved:
        return Command(goto="approved_path")
    else:
        return Command(goto="alternate_path")

# Adding node to the graph
graph_builder.add_node("human_approval", human_approval)
graph = graph_builder.compile(checkpointer=checkpointer)

# Simulating human input (resuming graph execution)
thread_config = {"configurable": {"thread_id": "some_id"}}
graph.invoke(Command(resume=True), config=thread_config)
```
### 🔍 **Explanation of Code:**
- **`interrupt(...)`** → Pauses execution and asks a human to approve.
- **`Command(goto="approved_path")`** → Moves forward if the action is approved.
- **`Command(goto="alternate_path")`** → Takes an alternate path if rejected.

---
### ✏️ **2. Review & Edit AI-Generated Text**
💡 **Scenario:** AI generates a **summary** for a report. A human reviews and **edits** the text before proceeding.

📌 **Steps:**
1. AI generates a draft summary.
2. The graph **pauses** for human review.
3. Human **edits** the text and **resumes** the workflow.

### **💻 Code Example: Review & Edit AI-Generated Text**
```python
from langgraph.types import interrupt

def human_editing(state):
    # Pause and let the human review the text
    result = interrupt(
        {
            "task": "Review the output from the LLM and make any necessary edits.",
            "llm_generated_summary": state["llm_generated_summary"]
        }
    )

    # Update the state with the human's edited text
    return {
        "llm_generated_summary": result["edited_text"]
    }

# Adding the node to the graph
graph_builder.add_node("human_editing", human_editing)
graph = graph_builder.compile(checkpointer=checkpointer)

# Simulating human input (resuming graph execution)
thread_config = {"configurable": {"thread_id": "some_id"}}
graph.invoke(Command(resume={"edited_text": "Revised summary"}), config=thread_config)
```
### 🔍 **Explanation of Code:**
- **`interrupt(...)`** → Pauses execution and requests human review.
- **`result["edited_text"]`** → Stores the human-edited text.
- **Workflow resumes** once the human input is received.

---
### ✋ **3. Explicitly Requesting Human Input**
💡 **Scenario:** AI is **missing context** (e.g., responding to an email) and requests human input before continuing.

📌 **Steps:**
1. AI reaches a point where additional context is required.
2. The graph **pauses** for human input.
3. The workflow **resumes** with human input.

### **💻 Code Example: Request Human Input**
```python
from langgraph.types import interrupt

def request_human_input(state):
    # Pause and ask for missing details
    user_input = interrupt(
        {
            "question": "Provide additional context for this task:",
            "current_task": state["task_description"]
        }
    )

    # Use human-provided input to update state
    state["additional_context"] = user_input
    return state

# Adding node to the graph
graph_builder.add_node("request_human_input", request_human_input)
graph = graph_builder.compile(checkpointer=checkpointer)

# Simulating human input
thread_config = {"configurable": {"thread_id": "some_id"}}
graph.invoke(Command(resume="More details about the task"), config=thread_config)
```
### 🔍 **Explanation of Code:**
- **`interrupt(...)`** → Pauses execution and asks a human for missing details.
- **`state["additional_context"] = user_input`** → Stores human-provided details.
- **Workflow resumes** once input is received.

---
## 🚀 **Real-World Applications of HITL**
| Scenario | Use Case |
|---|---|
| 🏦 **Financial Transactions** | Review and approve large or suspicious transactions before execution. |
| 📰 **Content Moderation** | Human editors review AI-generated summaries before publishing. |
| ⚖️ **Legal Compliance** | Lawyers validate AI-generated legal contracts. |
| 🎨 **Graphic Design** | Designers review AI-suggested edits before finalizing. |
| 🏥 **Medical Diagnosis** | Doctors confirm AI-suggested diagnoses before prescribing treatment. |

---
## 📌 **Key Takeaways**
✔️ **Human-in-the-Loop (HITL) workflows** improve AI reliability.  
✔️ The **`interrupt` function** in LangGraph enables workflow pausing.  
✔️ **Three main patterns**:  
   - **Approve or Reject** 🚦 (Decision-making).  
   - **Review & Edit** 📝 (Quality control).  
  

---

# 🔍 **Understanding Human Review in LLM Applications**  

In applications that involve **Large Language Models (LLMs)** interacting with tools or making decisions, **human review** is crucial to ensure accuracy, security, and correctness. This guide will help you understand the role of **human review nodes** in **LLM pipelines**, along with real-world use cases, Python code examples, and detailed explanations.  

---

## 🧑‍🏫 **What is a Human Review Node?**  

A **human review node** is a mechanism in an **LLM application** that allows human intervention before executing critical actions, such as:  
✅ Calling an external tool  
✅ Running sensitive code  
✅ Making irreversible changes  

This ensures that an **LLM does not execute incorrect or harmful actions** without human oversight.  

🔹 **Example Scenario**:  
Imagine a **financial chatbot** that assists users in transferring money. Before executing a transaction, it might ask for **human approval** to prevent unauthorized transfers.  

---

## 🏗️ **How Does a Human Review Node Work?**  

1️⃣ The LLM **suggests** an action (e.g., calling an API or executing a command).  
2️⃣ The **human review node interrupts** the process and asks, *"Should we proceed?"*  
3️⃣ The human reviewer can:  
   - ✅ **Approve** the action → The system executes it.  
   - ✏️ **Modify** the request → The system updates the action before execution.  
   - ❌ **Reject & provide feedback** → The system revises its approach.  

---

## 💻 **Python Code Example: Human Review Node in Action**  

Below is a Python implementation of a **human review node** using a structured LLM framework:  

```python
from typing import Literal
from langgraph.types import interrupt

def human_review_node(state) -> Literal["call_llm", "run_tool"]:
    """
    Function to create a human review node.
    
    Steps:
    1. Interrupts execution for human validation.
    2. Captures review action (continue, update, feedback).
    3. Proceeds based on human input.
    """

    # Display tool request for human approval
    tool_call = state.get("tool_call", {})
    human_review = interrupt(
        {
            "question": "Is this correct?",
            "tool_call": tool_call  # Surface tool call details for review
        }
    )

    # Extract human decision
    review_action, review_data = human_review

    if review_action == "continue":
        # Proceed with tool execution
        return "run_tool"

    elif review_action == "update":
        # Allow human to modify the request
        updated_message = review_data.get("updated_message")
        return {"goto": "run_tool", "update": {"messages": [updated_message]}}

    elif review_action == "feedback":
        # Log human feedback and request a new LLM response
        feedback_message = review_data.get("feedback_message")
        return {"goto": "call_llm", "update": {"messages": [feedback_message]}}
```

---

## 🧐 **Breaking Down the Code**  

### 📌 **Step 1: Define a Human Review Node**  
```python
def human_review_node(state) -> Literal["call_llm", "run_tool"]:
```
- This function acts as a **human review node**.  
- It receives the **current state** of the LLM pipeline.  
- It returns one of the following actions:  
  - `"call_llm"` → Modify the request and get a new response.  
  - `"run_tool"` → Proceed with executing the tool call.  

---

### 📌 **Step 2: Request Human Review**  
```python
human_review = interrupt(
    {
        "question": "Is this correct?",
        "tool_call": tool_call  # Show tool call details for review
    }
)
```
- The `interrupt` function **pauses execution** and prompts the human to review the tool request.  
- It surfaces **details of the tool call**, asking if it's correct.  

---

### 📌 **Step 3: Process Human Input**  
```python
review_action, review_data = human_review
```
- The human **chooses an action** (approve, modify, or reject).  
- Their decision is stored in `review_action`, and any additional input is in `review_data`.  

---

### 📌 **Step 4: Handle Review Decisions**  

#### ✅ **Option 1: Approve and Continue**  
```python
if review_action == "continue":
    return "run_tool"
```
- If the reviewer **approves**, the system proceeds with tool execution.  

#### ✏️ **Option 2: Modify Before Executing**  
```python
elif review_action == "update":
    updated_message = review_data.get("updated_message")
    return {"goto": "run_tool", "update": {"messages": [updated_message]}}
```
- If the reviewer **modifies the request**, the system **updates the message** before executing.  

#### ❌ **Option 3: Reject & Provide Feedback**  
```python
elif review_action == "feedback":
    feedback_message = review_data.get("feedback_message")
    return {"goto": "call_llm", "update": {"messages": [feedback_message]}}
```
- If the reviewer **rejects**, they provide feedback, and the system requests a **new LLM response**.  

---

## 🌍 **Real-World Use Cases**  

🔹 **1. AI-Powered Content Moderation**  
   - Before posting user-generated content, a **human review node** ensures compliance with content guidelines.  

🔹 **2. Medical AI Diagnosis**  
   - AI suggests a diagnosis, but a **human doctor reviews** before finalizing treatment.  

🔹 **3. Financial Fraud Detection**  
   - An LLM detects suspicious transactions, but a **fraud analyst reviews** before flagging an account.  

🔹 **4. Automated Resume Screening**  
   - AI shortlists candidates, but a **human reviewer** ensures fairness and quality.  

---

## 🚀 **Key Takeaways**  

✅ **Human review nodes prevent AI mistakes** and ensure **accuracy** in critical applications.  
✅ **Using interrupts**, we pause execution and seek human validation.  
✅ **Real-world applications** include content moderation, fraud detection, and healthcare AI.  
✅ **Carefully handling review actions** ensures smooth decision-making in AI workflows.  

By integrating human review nodes, **LLM applications become safer, more reliable, and more accountable**! 🚀

---


# 🛠️ **Understanding Human Review and Multi-Turn Conversations in LangGraph**  

When building **LLM-powered applications**, it’s essential to handle **human reviews** and **multi-turn conversations** effectively. These concepts ensure that **humans can verify AI-generated outputs** before proceeding and that the **system can engage in dynamic back-and-forth conversations with users**.  

This guide will cover:  
✅ **How to implement human review for sensitive AI-generated tool calls**  
✅ **How to design multi-turn conversations between humans and AI**  
✅ **Code examples with line-by-line explanations**  
✅ **Real-world applications of these concepts**  

---  

# 🔍 **1. Implementing Human Review in LangGraph**  

In **many AI applications**, tool calls may generate **sensitive information** or require **human oversight** before execution.  
For example, in **AI-assisted legal document drafting**, a human must **review** and **approve** the AI-generated legal terms before submission.  

### ✅ **How Human Review Works in LangGraph**  
1. **AI generates a tool call** (e.g., a request to call an API).  
2. **Execution is paused** (`interrupt()` is used to wait for human input).  
3. **A human reviews the tool call** and either:  
   - **Approves it** ✅ (execution continues)  
   - **Modifies it** ✏️ (updates the tool call before proceeding)  
   - **Rejects it with feedback** 🚫 (sends feedback to the AI to improve its response)  

---

## 📝 **Example: Implementing Human Review in LangGraph**  

```python
from langgraph.types import interrupt, Command
from typing import Literal

def human_review_node(state) -> Command[Literal["call_llm", "run_tool"]]:
    """
    Human review function to validate tool calls before execution.
    
    - Interrupts execution for human review.
    - Returns a command to continue, update, or give feedback.
    """

    # The AI generates a tool call (e.g., an API request)
    tool_call = state.get("tool_call", {})

    # Pause execution and wait for human review
    human_review = interrupt(
        {
            "question": "Is this correct?",
            "tool_call": tool_call  # Show the tool call for review
        }
    )

    # Human's decision
    review_action, review_data = human_review

    # If approved, continue execution
    if review_action == "continue":
        return Command(goto="run_tool")

    # If modified, update the tool call
    elif review_action == "update":
        updated_msg = get_updated_msg(review_data)  # Modify tool call
        return Command(goto="run_tool", update={"messages": [updated_msg]})

    # If feedback is given, send it back to the AI
    elif review_action == "feedback":
        feedback_msg = get_feedback_msg(review_data)
        return Command(goto="call_llm", update={"messages": [feedback_msg]})
```

---

### 📌 **Line-by-Line Explanation**  
🔹 **`def human_review_node(state)`** – This function handles human review of tool calls.  
🔹 **`tool_call = state.get("tool_call", {})`** – Retrieves the tool call generated by the AI.  
🔹 **`interrupt({...})`** – Pauses execution and asks a human, "Is this correct?"  
🔹 **`review_action, review_data = human_review`** – Stores the human's decision.  
🔹 **`if review_action == "continue"`** – If approved, execution continues.  
🔹 **`elif review_action == "update"`** – If modified, the updated tool call is used.  
🔹 **`elif review_action == "feedback"`** – If rejected, feedback is sent back to the AI.  

---

## 🎯 **Real-World Applications of Human Review**  
✅ **Medical AI Diagnostics** – Doctors review AI-generated diagnoses before prescribing treatments.  
✅ **AI-Generated Legal Contracts** – Lawyers approve contract terms before finalization.  
✅ **Financial Fraud Detection** – Bank officers review AI-detected fraudulent transactions before blocking accounts.  

---

# 🔄 **2. Multi-Turn Conversations in LangGraph**  

Multi-turn conversations involve **multiple back-and-forth interactions** between an **AI agent** and a **human**. This is useful when:  
✔️ The AI needs more information from the user.  
✔️ The user needs to refine their query.  
✔️ The conversation dynamically evolves.  

🔹 In **LangGraph**, multi-turn conversations involve:  
1. **A human input node** (`interrupt()` pauses execution).  
2. **An agent node** that processes the input and responds.  
3. **A loop** that continues the interaction until a stopping condition is met.  

---

## 📝 **Example: Multi-Turn Conversation in LangGraph**  

```python
from langgraph.types import interrupt, Command

def human_input(state):
    """
    Handles human input during a multi-turn conversation.
    Pauses execution and waits for the user's response.
    """
    
    # Pause execution and get user input
    human_message = interrupt("What would you like to do next?")

    # Store the user message in the conversation history
    return {
        "messages": [
            {
                "role": "human",
                "content": human_message
            }
        ]
    }

def agent(state):
    """
    AI agent logic to process user input and respond.
    """
    
    # Get the last user message
    user_message = state["messages"][-1]["content"]
    
    # Generate an AI response
    response = f"Agent received your message: {user_message}"

    # Store the AI response in the conversation history
    return {
        "messages": state["messages"] + [
            {"role": "agent", "content": response}
        ]
    }
```

---

### 📌 **Line-by-Line Explanation**  
🔹 **`def human_input(state)`** – Handles user input.  
🔹 **`interrupt("What would you like to do next?")`** – Pauses execution and waits for the user’s response.  
🔹 **`return {"messages": [{"role": "human", "content": human_message}]}`** – Stores the message in history.  
🔹 **`def agent(state)`** – Handles AI responses.  
🔹 **`state["messages"][-1]["content"]`** – Retrieves the last user message.  
🔹 **`response = f"Agent received your message: {user_message}"`** – Generates an AI response.  
🔹 **`return {"messages": state["messages"] + [{"role": "agent", "content": response}]}`** – Adds the AI response to the conversation history.  

---

## 🎯 **Real-World Applications of Multi-Turn Conversations**  
✅ **Customer Support Chatbots** – AI collects info and escalates issues when needed.  
✅ **AI-powered Virtual Assistants** – Conversational AI like Alexa and Siri.  
✅ **Job Interview Preparation Bots** – AI conducts mock interviews and provides feedback.  

---

# 🚀 **Conclusion: Combining Human Review and Multi-Turn Conversations**  

By **integrating human review and multi-turn conversations**, you can build **reliable and interactive AI applications**.  

🔹 **Human Review** ensures AI-generated actions are **safe and correct**.  
🔹 **Multi-Turn Conversations** allow AI to **gather more details** from users dynamically.  

✅ **Example Use Case: AI-Powered Legal Assistant**  
- AI **generates a contract** draft.  
- A **human lawyer reviews** and **modifies** it.  
- If the lawyer needs changes, a **multi-turn conversation** refines the document.  

These principles make AI **more interactive, safe, and user-friendly**. 🚀💡  

---

## 💬 **What’s Next?**  
Would you like a **full demo project** or more advanced implementations? Let me know! 😊

---

# 🛠️ Understanding Human Input Validation and Command Primitives in LangGraph  

When building applications with **LangGraph**, it is crucial to handle **human input validation** and manage **graph execution flow** efficiently. This ensures that incorrect or unexpected user inputs do not cause errors and that the system remains interactive and responsive.  

In this guide, we will explore:  
- **How to validate human input in LangGraph**  
- **How to use the `interrupt` function to pause execution**  
- **How to use the `Command` primitive to resume execution and modify state dynamically**  
- **Real-world use cases**  

---  

## 🔍 **Validating Human Input in LangGraph**  

Human input validation is essential in applications where user input affects the execution flow. Instead of relying on client-side validation, **LangGraph allows validation within the graph itself**.  

### ✅ **Example: Asking for a Valid Age**  

Below is an example where we ask the user for their **age** and validate that the input is a **positive integer**. If the input is invalid, the system asks again.  

```python
from langgraph.types import interrupt

def human_node(state: dict):
    """A human input node that validates user input."""
    question = "What is your age?"

    while True:
        answer = interrupt(question)  # Pause execution and wait for user input

        # Validate the input (ensure it's a positive integer)
        if not isinstance(answer, int) or answer < 0:
            question = f"'{answer}' is not a valid age. Please enter a valid age."
            continue  # Ask the question again
        else:
            break  # Exit loop if the input is valid

    print(f"The human in the loop is {answer} years old.")
    return {"age": answer}  # Return the validated age
```

### 🔹 **Explanation of the Code:**  
1. **`interrupt(question)`** – This pauses the graph execution and waits for the user to input their age.  
2. **Input validation** – The function ensures that the input is an integer and greater than 0.  
3. **Loop mechanism** – If the input is invalid, the question is asked again until valid input is received.  
4. **Return statement** – Once a valid age is entered, it is stored in the state dictionary and returned.  

### 🎯 **Real-World Use Case:**  
This logic can be applied in **customer onboarding forms**, where users must enter their age correctly before proceeding to the next step.  

---

## ⏸️ **The Command Primitive and Interrupt Handling**  

When execution reaches an `interrupt()`, the **graph pauses** until the user provides input. We need a way to **resume** execution once input is received.  

### ✅ **Resuming Execution with `Command(resume=value)`**  

```python
from langgraph.types import Command

# Resume graph execution with the user's input.
graph.invoke(Command(resume={"age": 25}), thread_config)
```

🔹 **Explanation:**  
- **`Command(resume={"age": 25})`** – This resumes the paused execution with the provided age value.  
- **`graph.invoke()`** – This restarts the graph execution after the interruption.  

### ✅ **Modifying the Graph State Dynamically**  

We can also **update** the graph state before resuming execution.  

```python
# Updating the state and resuming execution
graph.invoke(Command(update={"foo": "bar"}, resume="Let's go!!!"), thread_config)
```

🔹 **Explanation:**  
- **`Command(update={"foo": "bar"})`** – Updates the graph state by adding a new key-value pair (`foo: bar`).  
- **`resume="Let's go!!!"`** – Resumes execution while passing a message.  

---

## 🔄 **Handling Multi-Turn Conversations**  

In complex applications, a conversation might involve multiple turns of interaction.  

### ✅ **Example: Multi-Turn Conversation with Human Input**  

```python
from langgraph.types import interrupt

def human_input(state: dict):
    """Handles multi-turn user interaction."""
    human_message = interrupt("What would you like to do next?")
    
    return {
        "messages": [
            {
                "role": "human",
                "content": human_message
            }
        ]
    }

def agent_response(state: dict):
    """Agent response logic after human input."""
    user_message = state["messages"][-1]["content"]
    
    response = f"Agent received your message: {user_message}"
    return {"messages": state["messages"] + [{"role": "agent", "content": response}]}
```

🔹 **Explanation:**  
1. **`interrupt("What would you like to do next?")`** – Pauses execution and waits for user input.  
2. **Agent logic (`agent_response`)** – The system processes the last user message and generates a response.  

---

## 📌 **Real-World Applications**  

- **Customer Support Chatbots** – Chatbots can ask users clarifying questions before proceeding.  
- **Interactive Tutorials** – Software learning platforms can pause execution until users input correct data.  
- **AI Assistants** – Virtual assistants like **Siri and Alexa** wait for user input before taking action.  

---

## 🎯 **Final Thoughts**  

- **`interrupt()`** is used to pause execution and wait for user input.  
- **`Command(resume=value)`** resumes execution after getting valid input.  
- **Graph state can be modified dynamically** before resuming execution.  
- **Multi-turn interactions allow human-agent conversations** to be structured efficiently.  

These concepts help in designing **robust and interactive AI-driven applications**! 🚀

---

Great! I'll provide a **full demo project** combining **Human Review** and **Multi-Turn Conversations** using **LangGraph**. This will include:

✅ **A Python program where an AI assistant suggests actions, and a human reviews them before execution.**  
✅ **A multi-turn conversation loop that refines the AI-generated responses.**  
✅ **A step-by-step explanation of the entire code.**  

---

# 📌 **Project: AI-Powered Assistant with Human Review & Multi-Turn Conversations**  

### 🎯 **Scenario**  
We are building an **AI-powered task assistant** that:  
1️⃣ **Suggests actions** (e.g., "Send an email" or "Schedule a meeting").  
2️⃣ **Waits for human approval** before executing actions.  
3️⃣ **Engages in a multi-turn conversation** to refine tasks.  

---

## 📝 **Complete Python Code**  

```python
from langgraph.types import interrupt, Command
from typing import Literal

# Define the state of the system (stores conversation history)
state = {"messages": []}

def human_review_node(state) -> Command[Literal["call_llm", "run_tool"]]:
    """
    Handles human review for AI-generated actions.
    """

    # AI suggests an action
    suggested_action = "Schedule a meeting with the marketing team."

    # Store AI suggestion in state
    state["messages"].append({"role": "assistant", "content": suggested_action})

    # Pause execution and ask the human for review
    human_review = interrupt(
        {
            "question": f"AI suggests: '{suggested_action}'. Do you approve?",
            "options": ["Yes", "No", "Modify"]
        }
    )

    review_action = human_review  # Store human's response

    if review_action == "Yes":
        return Command(goto="execute_task")  # Proceed with execution
    elif review_action == "Modify":
        return Command(goto="refine_task")  # Modify task through conversation
    else:
        return Command(goto="end_conversation")  # End if rejected


def refine_task(state):
    """
    Multi-turn conversation to refine AI suggestions.
    """

    # Ask the human how they want to modify the task
    human_input = interrupt("How would you like to modify the task?")

    # Store human input
    state["messages"].append({"role": "human", "content": human_input})

    # AI refines the suggestion based on input
    refined_suggestion = f"Updated task: {human_input}"

    # Store the refined suggestion
    state["messages"].append({"role": "assistant", "content": refined_suggestion})

    # Ask for final review
    return Command(goto="human_review_node")


def execute_task(state):
    """
    Executes the approved task.
    """

    # Retrieve the last AI-approved task
    final_task = state["messages"][-1]["content"]

    print(f"✅ Executing task: {final_task}")  # Simulating execution

    return Command(goto="end_conversation")


def end_conversation(state):
    """
    Ends the conversation.
    """
    print("🛑 Conversation ended. No action taken.")
    return None  # Stops execution


# Simulate running the graph
print("🤖 AI Assistant is ready to assist you!")

# Start with human review
human_review_node(state)
```

---

## 📌 **How It Works (Step-by-Step)**  

### 🔹 **Step 1: AI Generates a Suggested Action**  
- AI suggests: **"Schedule a meeting with the marketing team."**  
- The system **pauses execution** (`interrupt()`) and **asks the human for approval**.  

### 🔹 **Step 2: Human Reviews the Suggestion**  
The user can:  
1️⃣ **Approve** ✅ (The task is executed).  
2️⃣ **Modify** ✏️ (Enters a multi-turn conversation to refine the task).  
3️⃣ **Reject** ❌ (The process stops).  

### 🔹 **Step 3: Refining the Task (If Needed)**  
- If the user **modifies** the task, a multi-turn conversation begins.  
- The system asks: **"How would you like to modify the task?"**  
- AI refines the task based on user input.  
- The modified task **goes back for human review**.  

### 🔹 **Step 4: Executing the Task**  
- If approved, the task is executed.  
- Example output: ✅ **Executing task: "Reschedule the meeting to Friday at 3 PM."**  

### 🔹 **Step 5: Ending the Conversation**  
- If the user rejects the task, the conversation ends.  

---

## 🎯 **Real-World Applications**  

✅ **AI Email Assistants** – AI drafts emails and waits for human approval.  
✅ **Task Automation Bots** – AI schedules tasks but allows human oversight.  
✅ **AI Chatbots in Customer Support** – AI suggests responses, but a human agent reviews them before sending.  

---

# 🚀 **What’s Next?**  
Would you like to see an **advanced version** with **GUI integration** or **database storage**? Let me know! 😊


---

# 📌 **How Resuming from an `interrupt()` Works in LangGraph**  

In **LangGraph**, an `interrupt()` is a mechanism that **pauses** execution, waits for user input, and then **resumes** execution. However, **resuming doesn't work like Python's `input()` function**—it **restarts execution from the beginning of the node** where the interrupt occurred.  

This guide will explain:  
✅ **How resuming works with `interrupt()`**  
✅ **Common pitfalls and best practices**  
✅ **How to avoid side effects**  
✅ **Real-world applications**  

---

# 🧠 **Understanding Resuming from `interrupt()`**

## 🔹 **What Happens When an `interrupt()` is Triggered?**  
When an **interrupt** occurs inside a node, execution is **paused**, and the system waits for user input. When the user provides input and the graph resumes:  
1. Execution **does NOT continue from the exact point of interruption**.  
2. Instead, it **restarts from the beginning of the node** where the `interrupt()` was called.  
3. Any **code before the `interrupt()` is re-executed**, which can cause unexpected behavior if not handled properly.  

---

## 📝 **Example 1: Basic `interrupt()` Behavior**

```python
from langgraph.types import interrupt
from typing import Dict

# Define the state dictionary
state = {"counter": 0}

def node(state: Dict):
    # Code before interrupt will re-run when resuming
    state["counter"] += 1
    print(f"> Entered the node: {state['counter']} # of times")

    # Pause execution and wait for user input
    answer = interrupt()

    # This will execute AFTER the user provides input
    print(f"The value of counter is: {state['counter']}")

# Simulating the node execution
node(state)
```

### 🖥 **Expected Output**
```
> Entered the node: 1 # of times
(User provides input)
> Entered the node: 2 # of times
The value of counter is: 2
```

### 🧐 **Explanation**
1️⃣ The **first time** the node runs, `counter = 1`, and execution is paused.  
2️⃣ When the user provides input, execution **resumes, but restarts from the beginning**.  
3️⃣ This causes `counter += 1` to run **again**, incrementing `counter` **twice** instead of once.  

---

# ⚠️ **Common Pitfalls & How to Avoid Them**  

## ❌ **1. Unintended Side Effects**  

### **Bad Example: API Calls Before `interrupt()`**
```python
from langgraph.types import interrupt

def human_node(state):
    # ❌ This API call will be repeated every time execution resumes!
    api_call()

    # Pause execution and wait for input
    answer = interrupt()
```

### 🔴 **Problem**
Every time the node **restarts from the beginning**, the `api_call()` will **run again**, potentially:  
- Making **duplicate API requests**  
- Causing **billing issues** if the API is expensive  
- Fetching **inconsistent data**  

### ✅ **Solution: Move Side Effects After the `interrupt()`**
```python
def human_node(state):
    # Pause execution and wait for input
    answer = interrupt()

    # ✅ Now, the API call happens only once, after resumption
    api_call()
```

---

## ❌ **2. Using `interrupt()` in Subgraphs Incorrectly**  
### **Example: Parent Graph and Subgraph Execution**
```python
def node_in_parent_graph(state):
    some_code()  # ❌ This will re-run every time the subgraph resumes!

    # Call a subgraph that contains an `interrupt()`
    subgraph_result = subgraph.invoke(some_input)
```
### 🔴 **Problem**
- The **parent graph will restart from the beginning of this node** whenever the subgraph resumes.
- **Unintended behavior** may occur if `some_code()` modifies the state in a way that shouldn't be repeated.

### ✅ **Solution: Use a Separate Node for State Updates**
Instead of modifying state in the **same node as the subgraph call**, move it to a **separate node**.

---

## ❌ **3. Multiple `interrupt()` Calls in One Node**
Using multiple `interrupt()` calls **in the same node** can cause **unpredictable behavior**.  
LangGraph **remembers inputs by index**, so if the number of `interrupt()` calls changes, inputs may **no longer match correctly**.

### **Bad Example: Changing the Order of `interrupt()` Calls**
```python
def node(state):
    answer1 = interrupt("First question?")
    if some_condition:
        answer2 = interrupt("Second question?")
```
### 🔴 **Problem**
- If `some_condition` changes between executions, the number of `interrupt()` calls **is different**.  
- This causes **index mismatches**, leading to **incorrect inputs being retrieved**.

### ✅ **Solution: Keep `interrupt()` Calls Consistent**
Ensure **all `interrupt()` calls always execute in the same order**.

---

# 🎯 **Real-World Applications of `interrupt()`**
✅ **Human-in-the-loop AI Systems** – AI suggestions pause for human approval before executing actions.  
✅ **Workflow Automation** – Tasks like **document approval** or **manual input validation** require pauses.  
✅ **AI Chatbots with User Confirmation** – A bot suggests a response but waits for a human before sending it.  

---

# 🚀 **Final Thoughts**
🔹 **Resuming execution after an `interrupt()` restarts from the beginning of the node.**  
🔹 **Avoid placing API calls and side effects before `interrupt()`, or they'll be repeated.**  
🔹 **Be careful when using multiple `interrupt()` calls in the same node.**  

Would you like a **practical project** that uses `interrupt()` in a real-world scenario? 😊