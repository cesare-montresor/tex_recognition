# tex_recognition

*Using computer vision techniques to recognize and highlight defects in a textile image.*

| **Notes**

- Files must follow the following rules for the script to work:

  - All input files must be put into the *defect_images* folder

  - File name must follow the format *iXX.jpg*, where XX is a number

    

- *tex_analysis.m* is the main file for the project.

- Files with format *\*_.m*, aka ending in underscore, are currently unused.
- All files still need to be properly commented (the only kinda-decent one is tex_analysis.m).
- *observer_\*.m* are files I use for testing visually what kind of result I can obtain with these function. Usually they try multiple values on the function and show them fastly, so I can note what value is visually the best (and hence what an automatic algorithm should find).
- Code is prefaced with a *Settings* section, where you can set variable to edit the script's behaviour. 
  For example, you can choose to examine a random image, examine a single image or do batch analysis for the whole folder, or you can enable/disable figures.