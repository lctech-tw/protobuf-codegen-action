# 🚀 **Usage Guide**

## 📚 **Introduction**  
This project includes a **GitHub Actions** workflow defined in a custom **`action.yml`** file located in the repository root. This action is designed for **[briefly describe the purpose, e.g., automated testing, CI/CD deployment, code formatting, etc.]**.

---

## 🛠️ **Features**

- Automatically generate Proto documentation and update the README file with the latest changes, ensuring documentation stays consistent with code updates. 

---

## 📦 **File Structure**

```plaintext
.
├── action.yml      # GitHub Actions configuration file
└── README.md       # Documentation for this action
```

- **`action.yml`**: Defines the core logic and metadata for the GitHub Action.  
- **`README.md`**: Provides documentation and usage instructions (you are reading it now).  

---

## 🚀 **How to Use This GitHub Action**

### **1. Reference the Action in Your Workflow**

To use this GitHub Action, create a workflow file in your repository (e.g., `.github/workflows/main.yml`) and reference your custom action:

```yaml
name: Example Workflow

on:
  push:
    branches:
      - main

jobs:
  example-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Compile
        uses: lctech-tw/protobuf-codegen-action@v0
```
<!-- 
---

### **2. Define Inputs (if applicable)**

If your `action.yml` defines `inputs`, make sure to pass them correctly in your workflow:

**Example `action.yml` Input Definition:**
```yaml
inputs:
  input1:
    description: 'Description for input1'
    required: true
  input2:
    description: 'Description for input2'
    required: false
```

**Workflow Example with Inputs:**
```yaml
with:
  input1: 'value1'
  input2: 'optional_value'
```

---

### **3. Outputs (if applicable)**

If your `action.yml` defines `outputs`, you can reference them in your workflow:

**Example `action.yml` Output Definition:**
```yaml
outputs:
  result:
    description: 'Result of the action'
```

**Workflow Example with Outputs:**
```yaml
- name: Display Action Result
  run: echo "Result: ${{ steps.example-job.outputs.result }}"
```

---

## ⚙️ **Example `action.yml` File**

Here’s an example of how your `action.yml` might look:

```yaml
name: 'Custom GitHub Action'
description: 'An example GitHub Action to perform a custom task'
inputs:
  input1:
    description: 'First input value'
    required: true
  input2:
    description: 'Second input value'
    required: false
outputs:
  result:
    description: 'The result of the action'
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - ${{ inputs.input1 }}
    - ${{ inputs.input2 }}
``` -->

---

## 🔍 **FAQ**

### **Q1: How do I debug the action if it fails?**  
- Go to the **Actions** tab in your repository.  
- Select the failed workflow run.  
- Check the **logs** to identify errors.

### **Q2: How do I manually trigger this action?**  
- Add a `workflow_dispatch` event to your workflow YAML:
```yaml
on:
  workflow_dispatch:
```

---

## 🤝 **Contributing**

Contributions are welcome! If you'd like to improve this action:

1. **Fork** this repository.  
2. Create a new branch: `git checkout -b feature/your-feature`.  
3. Make your changes and commit: `git commit -am 'Add new feature'`.  
4. Push to your branch: `git push origin feature/your-feature`.  
5. Submit a Pull Request.  

