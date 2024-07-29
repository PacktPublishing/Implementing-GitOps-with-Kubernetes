# Implementing GitOps with Kubernetes

<a href="https://www.packtpub.com/en-in/product/implementing-gitops-with-kubernetes-9781835884225?utm_source=github&utm_medium=repository&utm_campaign=9781786461629"><img src="https://content.packt.com/_/image/xxlarge/B22100/cover_image_large.jpg" alt="Implementing GitOps with Kubernetes" height="256px" align="right"></a>

This is the code repository for [Implementing GitOps with Kubernetes](https://www.packtpub.com/en-in/product/implementing-gitops-with-kubernetes-9781835884225?utm_source=github&utm_medium=repository&utm_campaign=9781786461629), published by Packt.

**Automate, manage, scale, and secure infrastructure and cloud-native applications on AWS and Azure**

## What is this book about?
This book provides step-by-step tutorials and hands-on examples for effectively implementing GitOps practices in your Kubernetes deployments. You’ll learn how to automate, monitor, and secure your infrastructure for efficient application delivery.


This book covers the following exciting features:
* Delve into GitOps methods and best practices used for modern cloud-native environments
* Explore GitOps tools such as GitHub, Argo CD, Flux CD, Helm, and Kustomize
* Automate Kubernetes CI/CD workflows using GitOps and GitHub Actions
* Deploy infrastructure as code using Terraform, OpenTofu, and GitOps
* Automate AWS, Azure, and OpenShift platforms with GitOps
* Understand multitenancy, rolling back deployments, and how to handle stateful applications using GitOps methods
* Implement observability, security, cost optimization, and AI in GitOps practices

If you feel this book is for you, get your [copy](https://www.amazon.com/dp/1835884237) today!

<a href="https://www.packtpub.com/?utm_source=github&utm_medium=banner&utm_campaign=GitHubBanner"><img src="https://raw.githubusercontent.com/PacktPublishing/GitHub/master/GitHub.png" 
alt="https://www.packtpub.com/" border="5" /></a>

## Instructions and Navigations
All of the code is organized into folders. For example, Chapter02.

The code will look like the following:
```
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets
#Install e.g. CLI on MacOS
brew install kubeseal
```

**Following is what you need for this book:**
This book is for DevOps engineers, platform engineers, SREs, and cloud engineers who want to get skilled at implementing GitOps practices effectively in cloud-native environments. A foundational understanding of cloud computing, containerization, infrastructure as code, DevOps, CI/CD principles, and Kubernetes will be helpful to get the most out of this book.

With the following software and hardware list you can run all code files present in the book (Chapter 1-14).
### Software and Hardware List
| Chapter | Software required | OS required |
| -------- | ------------------------------------ | ----------------------------------- |
| 1-14 | Kubernetes | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Git | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Docker | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Argo CD | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Flux CD | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Helm | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Kustomize | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Terraform | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Azure Kubernetes Service (AKS) | Windows, Mac OS X, and Linux (Any) |
| 1-14 | AWS Elastic Kubernetes Service (EKS) | Windows, Mac OS X, and Linux (Any) |
| 1-14 | OpenShift | Windows, Mac OS X, and Linux (Any) |


### Related products
* Automating DevOps with GitLab CI/CD Pipelines [[Packt]](https://www.packtpub.com/en-in/product/automating-devops-with-gitlab-cicd-pipelines-9781803233000?utm_source=github&utm_medium=repository&utm_campaign=) [[Amazon]](https://www.amazon.com/dp/1803233001)

* Modern DevOps Practices [[Packt]](https://www.packtpub.com/en-in/product/modern-devops-practices-9781805121824?utm_source=github&utm_medium=repository&utm_campaign=) [[Amazon]](https://www.amazon.com/dp/1805121820)

## Get to Know the Author
**Pietro Libro**
is a tech enthusiast with over two decades of experience in software development and software architecture. His pragmatic problem-solving skills have been honed through work in the public administration, finance, and automation industries. He holds a master’s degree in computer science from the University of Rome, La Sapienza. Over the years, Pietro has transitioned from software development to a solution and cloud architect role. He is currently awaiting the defense of his PhD in bioinformatics at the University of Tuscia. Pietro’s dedication to learning is evident through his numerous certifications and his role as a technical speaker. Specializing in various technologies, especially software and cloud architecture, he relocated from Italy to Switzerland. Currently serving as a cloud solution architect in Zürich, Pietro lives with his wife, Eleonora, his daughter, Giulia, and their cat, “Miau”. In his free time, Pietro enjoys biking, practicing taekwondo, watching science fiction movies and series, and spending time with his family.


**Artem Lajko**
is a passionate and driven platform engineer and Kubstronaut, boasting over eight years of IT experience, backed by a master’s degree in computer science. His track record showcases expertise in designing, developing, and deploying efficient and scalable cloud infrastructures. As a curious and continuous learner, Artem holds certifications in Azure, AWS, Kubernetes, and GitOps. Currently, he’s playing a pivotal role in enhancing innovation and application management at the Port of Hamburg. His technical acumen spans cloud infrastructures, cross-cloud solutions, and DevOps practices. He is also passionate about blogging and networking with manufacturers to craft top-notch solutions using market-available tools.

