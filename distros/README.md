# Distribution specific Dockerfiles

## Requirements

### Dockerfile name
The format should be `Dockerfile.{distribution name}`.  

### Keep your images up-to-date
Use the distribution package manager to keep your image up-to-date.

### REPOSITORY
Add a `REPOSITORY` comment with the URL to your GitHub repository where the Dockerfile is present.   
`# REPOSITORY <GitHub repository>`  

### MAINTAINER
Add the `MAINTAINER` instruction and your contact details, GitHub aliases are acceptable.   

For an example Dockerfile, please refer to `Dockerfile.alpine`.
