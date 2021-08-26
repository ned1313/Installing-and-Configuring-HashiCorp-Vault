# Installing-and-Configuring-HashiCorp-Vault

Exercise files for use with the Pluralsight course Installing and Configuring HashiCorp Vault

## Introduction

Hello! These are the exercise files to go with my Pluralsight course, Installing and Configuring HashiCorp Vault

## Prerequisites

You are going to need some software installed locally, an Azure account, and a public domain. Here's a list of software you should have installed:

* Azure CLI
* Vault
* Terraform
* OpenSSL
* Kubectl
* Helm
* GPG

We will be using Microsoft Azure as the deployment target for resources. We are also going to use Let's Encrypt to procure TLS certificates for Vault. You're going to need a public domain and access to DNS for that domain to successfully get the certificate.

Deployment of resources will be done through HashiCorp Terraform. You do not need prior Terraform experience to complete these exercises!

## Using the files

Each folder represents a module from the course. In each module are numbered files that contain the commands you should run to follow along. I've provided both a PowerShell and Bash version of the commands, so you can roll with whichever shell environment you like best. Personally, I run Bash on Ubuntu on Windows Subsystem for Linux. I've found that much of the Vault documentation assumes you're using Bash or Zsh.

## Cost

You are going to deploy a standalone Vault server running on an Azure VM, an AKS cluster, and a Vault cluster using Azure VMs. I've done my best to use small instances sizes to keep the cost down. That being said, you may end up spending some small amount of money in Azure. Be sure to shut down or delete each environment when you are done using it!

## Public domain

The exercises assume you have a public domain registered and can make changes to it's DNS records. There are numerous domain registrars that offer second tier top-level domains for only $0.99 for the first year. The .xyz domain in particular is super cheap. After a year it will bump up to something close to $15. If you only need the domain for these exercises, simply turn off auto-renewal.

If you really don't want to buy a domain, you could use a self-signed certificate. But I think there is value in going through the process of procuring certificates with Let's Encrypt and certbot. 

## Certification

This course is not intended to prepare you for the HashiCorp Vault Associate level certification. There are two other courses on Pluralsight specifically around that topic. This course is intended for someone who wants to run Vault in production. There is also a Vault Administrator certification in development (name subject to change). This course will definitely help with that certification, once it goes live.

## Thank You!

I hope you enjoy taking this course as much as I did creating it. I'd love to hear feedback and suggestions for revisions.

Thanks and go build something awesome!

Ned