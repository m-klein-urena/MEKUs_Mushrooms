library(shiny)
library(tidyverse)
library(magrittr)
library(randomForest)
library(factoextra)
library(cluster)
library(fastDummies)
set.seed(2022)

ui <- fluidPage(
    titlePanel("Mushroom Classifier"),

    tabsetPanel(
      tabPanel("Introduction",
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width =3,
                        p(strong("Case Study 3"), align = "left", style = ("font-size:18px")),
                        p("Author:", span(em("Michael Klein"))),
                        p("Course:", span(em("Introduction to Data Science"))),
                  #End Column   
                  ),
                
                  column(class =  "column_w_bar", width =2,
                         img(src = "https://cdn.pixabay.com/photo/2013/06/05/22/03/mushrooms-116973_1280.jpg",
                             width = "100%")
                  #End Column            
                  ),
                
                  column(class =  "column_w_bar", width =2,
                         img(src = "https://cdn.pixabay.com/photo/2019/01/02/00/06/mushroom-3907809_1280.jpg",
                             width = "100%")
                  #End Column             
                  ),
                
                  column(class =  "column_w_bar", width =2, 
                         img(src = "https://cdn.pixabay.com/photo/2017/12/16/22/52/mushroom-3023460_1280.jpg",
                             width = "100%")
                  #End Column             
                  ),
                 
                 column(class =  "column_w_bar", width =2,
                        img(src = "https://cdn.pixabay.com/photo/2017/05/02/22/43/mushrooms-2279558_1280.jpg",
                            width = "100%")
                  #End Column             
                  )
               #End Fluid Row   
               ),
               
               hr(),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p("This project/case study allows the user to classify groups of mushrooms into different species as well as edibility (edible or poisonous) in two distinct features:"),
                        tags$ol(tags$li(strong("Is it Poisonous??:"), "A prediction model that determines whether a mushroom is poisonous based on multiple physical attributes"), tags$li(strong("Species Classifier:"), "A K-means based classifier that groups mushrooms into ", span(em("K"))," number of groups specified by the user.")),
                        p(strong("Description of the Dataset"), style = ("font-size:14px")),
                        p("Data for this project was sourced from the ", span(a(href = "https://archive.ics.uci.edu/ml/datasets/mushroom", "UCI Machine Learning Repository")),
                          "mushroom dataset. The dataset contains 23 attributes of over 8,000 specimens, including whether the mushroom is edible or poisonous. All specimens collectively belong to a certain number of species (you can explore exactly how many species there are with the Species Classifier)"),
                        p("I selected this dataset not only because of personal interests (see motivations below), but because of the abundance of records as well as features. This would make both prediction and classification tasks much more accurate and meaningful."),
                        p("This data product utilizes a Random Forest machine learning algorithm (edibility predictor) and a K-means algorithm (species classifier). For more details on algorithm design and results, please see the \"ML Description and Results\" tab.")
                  #End Column               
                  )
                #End Fluid Row   
                ),
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 br(),
                 column(class =  "column_w_bar", width = 4,
                        img(src = "https://cdn.pixabay.com/photo/2014/11/04/08/13/fly-agaric-516281_1280.jpg",
                            width = "100%")
                  #End Column
                  ),
                 
                 column(class =  "column_w_bar", width = 8,
                        p(strong("Motivation"), align = "left", style = ("font-size:18px")),
                        p("In fall 2020, I was hiking my way through the Black Forest of Germany. During this 10-day journey through this beautiful landscape, I came across several varieties of mushrooms along the path. Between being a lover of mushrooms and being obsessed with minimizing my pack weight, I lamented that there was no easy way to identify mushrooms that might be edible or poisonous."),
                        p("Sure, there are field guides, but it could take quite a while to flip through pages of descriptions. And while there are photo identification apps available for both Android and iPhone, one can’t rely on reliable internet connection in the middle of the of forest, and storing an entire database of mushroom photos on one’s phone can take up a lot of space. Solving this problem is the motivation behind the first part of this project."),
                        p("The motivation behind the second portion of this project, which employs cluster analysis, is to tackle a related question: what’s the easiest and fastest way to determine what species of mushrooms exist within a certain area when relying on citizen scientists who may not be experts in species classification?")
                       
                  #End Column        
                  )
                #End Fluid Row
                ),
               
               hr(style = "border-top: 1px solid #000000;"),
               fluidRow(
                 column(class =  "column_w_bar", width = 8,
                        p(strong("Business Value"), align = "left", style = ("font-size:18px")),
                        p("The edibility predictor and species classifier offer a unique value to individual hikers and local conservation organizations, respectively."),
                        p("The edibility predictor helps resolve an important question for hikers and amateur mycologists: what if there was a way to detect whether a mushroom was poisonous or not by entering in a few simple characteristics that could easily identify a mushroom’s edibility using just a text file and a simple ML algorithm? This is exactly how the edibility predictor is designed. As a stand-alone app, it would be easy to store the ML model and apply it to newly encountered specimens. However, it should be noted that the UCI dataset covers only a few specific species. A release-ready app would need an ML model that incorporates far more data, though the model itself would still take up little storage space compared to a photo database."),
                        p("The classifier, on the other hand, is helpful to scientist and naturalist in the lab. While citizen science is an excellent way to get the community more engaged with the natural environment, there are some limitations — namely, that many volunteers may not be experts in identifying local species, even if they may be good at recording specimen characteristics. This cluster analysis tool can help local naturalists quickly put together hundreds or even thousands of citizen scientist observations to help determine the number of mushroom species in a given area. This can then be used to further identify which mushroom genus or species formed by each cluster.")
                  # End Column        
                  ),
                 
                 br(),
                 
                 column(class =  "column_w_bar", width = 4,
                        img(src = "https://cdn.pixabay.com/photo/2017/09/11/17/19/mushroom-2739730_1280.jpg",
                            width = "100%")
                  # End Column    
                  )
                # End Fluid Row  
                )
      #End Tab Panel
      ),

      tabPanel("ML Descriptions and Results",
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Random Forest: Edibility Prediction"), align = "left", style = ("font-size:18px")),
                        p("The machine learning algorithm used in this project is a random forest model, that is, a collection of different decision tree models. In making a prediction, the input data is passed into each decision tree, which makes an individual prediction of the target class — in this case, edible or poisonous. The results of each tree are then tallied, and the class with the most “votes” is passed to the model output."),
                        p("I opted for a decision tree model because this is a \"white-box\", meaning that it's possible to understand how different attributes play a role in classification and prediction. This would be important to naturalist who may want to understand the most telling predictors of mushroom edibility. The higher a feature is on the decision tree, the more people should focus on it when determining edibility"),
                        p("However, decision trees aren't perfect, and they can easily change with the introduction of a new data point. To mitigate this, I chose to use the random forest ensemble method to make it less likely that a new value or outlier would significantly affect the prediction model."),
                        p("One of the nice things about this dataset is that it’s possible to achieve 100% accuracy using all 22 features of the data. However, since users need to specify each input parameter, using every attribute would make the data product more cumbersome and less appealing. Instead, I chose to include a subset of just 9 attributes that could still classify edibility without substantially reducing the accuracy of the model. The selected attributes focus on the mushroom cap and gills, as well as odor and spore print color. All of these attributes could be easily identified by even a novice mushroom enthusiast."),
                        p(strong("Setting Up the Model"), align = "left", style = ("font-size:16px")),
                        p("First, the original dataset was divided into a training and test set. 80% of the data records would be used to train the model while the other 20% would be used to validate that the model is accurate without being overfitted."),
                        p("The end model uses 100 random trees to make a prediction. Plotting the model results, it’s clear that using more trees would increase computation time without improving the accuracy of the results for our test set.")
                        
                        
                  #End Column
                  )
               # End Fluid Row    
               ),

               fluidRow(
                 column(class =  "column_w_bar", width = 4,
                        p(strong("Results: Random Forest"), align = "left", style = ("font-size:16px")),
                        p("As can be seen from the error plot, the model does an extremely accurate job at predicting edibility for both poisonous and edible specimens using just the 9 features. However, having more than about 80 trees doesn't seem to improve the accuracy."),
                        p("The training accuracy results for the training and test sets of the model are shown below. With an error rate of less than 0.05% and almost no false negatives or positives on the test set predictions, this seems like a acceptable compromise between accuracy and feature count."),
                        p("Interesting to note is that mushroom odor seems to play an important role in predicting edibility. Changing the odor alone is most likely to change the model prediction. Give it a try!")
                 #End Column     
                 ),
                 
                 column(class =  "column_w_bar", width = 8,
                        plotOutput("rf_plot")
                 #End Column
                 )
               #End Fluid row 
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p("What's especially impressive is that the model has no false positives, that is, the model doesn't falsely predict mushrooms to be edible when they're really poisonous. In this case, a false positive is much worse than a false negative, where the model predicts an edible mushroom to be poisonous.")
                 #End Column   
                 )
               #End Fluid Row   
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 8,
                        p(strong("Training Set Error and Confusion Matrix"), align = "left", style = ("font-size:14px")),
                        verbatimTextOutput("rf_summary")
                 #End Column
                 ),
                 
                 column(class =  "column_w_bar", width = 4,
                        p(strong("Test Set Confusion Matrix"), align = "left", style = ("font-size:14px")),
                        tableOutput("test_set_cf")
                 #End Column
                 )
               #End Fluid Row   
               ),
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Species Classifier: K-Means Clustering"), align = "left", style = ("font-size:18px")),
                        plotOutput("cluster_plot_2")
                 # End Column        
                 )
               #End Fluid Row   
               ),
               
               hr(),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p("I chose K-means clustering as a way to visualize how many different species are represented in the mushroom dataset. K-means classification is an example of unsupervised machine learning, that is, the algorithm groups records into similar clusters without any a priori knowledge of what a cluster should look like. This is perfect for something like species classification, where It may not be possible to know ahead of time which species might be represented in a given sample of mushrooms, or even how many different species there might be."),
                        p("While our all-categorical feature set is ideal for decision tree and random forest classifier, it actually poses a problem for K-means clustering, which typically works best with continuous variables to determine the shortest Euclidean distance (highest similarity measure) between points. One way to overcome this is to use K-medoids classification, which is designed to work with categorical data (or factors in R). However, I found that this method, using the", span(em("kmodes")), "library in R, was so computationally intensive for large values of K that it would make it impossible for anyone to effectively use the data product."),
                        p("The solution I chose was to stick to faster K-means algorithm while dummy-coding all variables. While this resulted in a much higher number of features — over 100 after dummy coding — it was then possible to use K-means by specifying Manhattan distance rather than Euclidean distance (the former measure is better for determining distance between binary attributes or ordered factors).")
                        
                 #End Column
                 ),
                 
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Setting Up the Model"), align = "left", style = ("font-size:16px")),
                        p("As an unsupervised ML algorithm, K-means is fairly simple to set up in R. The most important parameter is,", span(em("K")), ", the number of desired clusters. Here, ", span(em("K")), ", corresponds to the number of species in the dataset and can be selected by the user with a sliding scale."),
                        p("One challenge of this model is the difficulty in visualizing the dataset as new clusters are formed. The best way to visualize K-means is a principal component analysis (PCA) plot that will project the points such that they’re the most spread out. However, since even the first PC of the analysis doesn’t account for much variation in the data (< 20%), a lot of clustered points overlap each other."),
                 #End Column
                 )
               #End Fluid Row
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 5,
                        p("To help the user better visualize the effectiveness of the clusters, I added a stacked bar chart showing the distribution of edibility across data points in each cluster. The reasoning is that, while mushrooms of the same species may show some variability in shape and color, all mushrooms of a given species should be either edible or poisonous. Thus, the bar chart will help the user see how well the clusters are separating the dataset. If all bars in the plot are 100% green or 100% red, then we know that we’ve grouped the data into the right number of clusters/species.")
                 #End Column
                 ),
                 
                 column(class =  "column_w_bar", width = 7,
                        plotOutput("cluster_bars_2")
                 # End Column        
                 )
               #End Fluid Row   
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Results: K-Means Clustering"), align = "left", style = ("font-size:16px")),
                        p("The K-means algorithm is successful in that it quickly reacts to user changes; however, the bar plots show the difficulty in choosing the right number of clusters. From ", span(em("K")), "= 2 to ", span(em("K")), "= 50, there were no results that neatly grouped mushrooms into all-edible and all-poisonous clusters. This may very well show the limits of using K-clustering on datasets with all non-ordinal categorical features."),
                        p("Another potential issue may have to do with the algorithm itself. Given how close data points are to each other, the initial centroids chosen by the algorithm have a big effect on the end results."),
                        p("There are a few methods of selecting initial centroids for K-means analysis, including through stratified sampling, but it looks like there’s no way to manually adjust the initial centroids in this R package. It would be interesting to explore this dataset using a clustering algorithm with more flexibility on selecting initial centroids.")
                 #End Column
                 )
                #End Fluid Row
               )
               
      #End Tab Panel  
      ),
      
      #Start organizing here
      tabPanel("Is it Poisonous???",
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Instructions"), align = "left", style = ("font-size:18px")),
                        p("This predictor will determine whether a mushroom is edible or poisonous based on features you'll find on the mushroom cap and gills. Read through each description and select the option from the drop-down menus that most closely resemble your specimen. Then click on the button below to see your results.")
                 #End Column
                 )
               #End Fluid Row
               ),
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Mushroom Caps"), align = "left", style = ("font-size:18px")),
                        p("For many people, the cap, or upper part, of the mushroom is the most visible and easy to identify. Mushroom caps come in all shapes, sizes, textures and colors."),
                        p("Carefully inspect your mushroom cap. What do you see?"),
                        p("Select the mushroom cap features that correspond most closely to your specimen."),
                        br()
                        
                  #End Column
                  )
               #End Fluid Row
               ), 
               
               fluidRow(
                 column(class =  "column_w_bar", width = 4,
                        
                        br(),
                        
                        selectInput("cap_shape", "Cap Shape:",
                                  c("Bell" = "b",
                                    "Conical" = "c",
                                    "Convex" = "x",
                                    "Flat" = "f",
                                    "Knobbed" = "k",
                                    "Sunken" = "s")),
                        
                        selectInput("cap_surface", "Cap Surface:",
                                    c("Fibrous" = "f",
                                      "Grooves" = "g",
                                      "Scaly" = "y",
                                      "Smooth" = "s")),
                 
                        selectInput("cap_color", "Cap Color:",
                                    c("Brown" = "n",
                                      "Buff" = "b",
                                      "Cinnamon" = "c",
                                      "Gray" = "g",
                                      "Green" = "r",
                                      "Pink" = "p",
                                      "Purple" = "u",
                                      "Red" = "e",
                                      "White" = "w",
                                      "Yellow" = "y"))
                 #End Column
                 ),
                 
                 column(class =  "column_w_bar", width = 8, style = "border-left: 0.5px solid #000000;",
                        img(src="https://biolwww.usask.ca/fungi/graphics/glossary_pictures/glossary_pic15",
                            width="90%"),
                        p(em("Examples of mushroom cap shapes")),
                        
                        br(),
                        
                        img(src="https://biolwww.usask.ca/fungi/graphics/glossary_pictures/glossary_pic16",
                            width="90%"),
                        p(em("Examples of mushroom cap textures."))
                   
                 
                   #End Column
                   )
               #End Fluid Row
               ),
               
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        p(strong("Mushroom Gills"), align = "left", style = ("font-size:16px")),
                        p("Mushroom gills, or ", span(em("lamella")), ", are used to release spores. Flip your mushroom upside-down and take a look at the gills. What do you notice?"),
                        p("Select the mushroom gill features that correspond most closely to your specimen."),
                        
                        br()
                        
                 #End Column
                 )
               #End Fluid Row
               ), 
              
               fluidRow(
                 
                 column(class =  "column_w_bar", width = 4,
                        
                        br(),
                        
                        selectInput("gill_attachment", "Gill Attachment:",
                                    c("Attached" = "a",
                                      "Descending" = "d",
                                      "Free" = "f",
                                      "Notched" = "n")),
                 
                        selectInput("gill_spacing", "Gill Spacing:",
                                    c("Crowded" = "w",
                                      "Close" = "c",
                                      "Distant" = "d")),
                 
                        selectInput("gill_size", "Gill Size:",
                                    c("Broad" = "b",
                                      "Narrow" = "n")),
                 
                        selectInput("gill_color", "Gill Color:",
                                    c("Black" = "k",
                                      "Brown" = "n",
                                      "Buff" = "b",
                                      "Chocolate" = "h",
                                      "Gray" = "g",
                                      "Green" = "r",
                                      "Orange" = "o",
                                      "Pink" = "p",
                                      "Purple" = "u",
                                      "Red" = "e",
                                      "White" = "w",
                                      "Yellow" = "y")),
                 
                 #End Column
                 ),
                 
                 br(),
                 
                 column(class =  "column_w_bar", width = 8, style = "border-left: 0.5px solid #000000;",
                        img(src="https://biolwww.usask.ca/fungi/graphics/glossary_pictures/glossary_pic19",
                            width="90%"),
                        p(em("Examples of gill attachment types")),
                        
                        br(),
                        br(),
                        
                        img(src="https://biolwww.usask.ca/fungi/graphics/glossary_pictures/glossary_pic17",
                            width="60%"),
                        p(em("Examples of gill spacing"))
                        
                        
                 #End Column
                 )
              #End Fluid Row
              ),
               
              hr(style = "border-top: 1px solid #000000;"),
                
              fluidRow(
                column(class =  "column_w_bar", width = 6,
                       p(strong("Other Features"), align = "left", style = ("font-size:16px"))
                #End Column 
                )
              #End Fluid Row   
              ),
               
              fluidRow(
                column(class =  "column_w_bar", width = 6,
                       selectInput("odor", "Odor:",
                                   c("Almond" = "a",
                                     "Anise" = "l",
                                     "Creosote" = "c",
                                     "Fishy" = "y",
                                     "Foul" = "f",
                                     "Musty" = "m",
                                     "None (Odorless)" = "n",
                                     "Pungent" = "p",
                                     "Spicy" = "s")),
                       p("Odor is an important feature used in mushroom identification. In fact, this model uses odor as one of the first deciding factors when predicting whether a mushroom is poisonous."),
                       p("Take a gentle whiff of your mushroom. What do you smell?")
                #End Column  
                ),
                
                column(class =  "column_w_bar", width = 6,
                       selectInput("spore_print_color", "Spore Print Color:",
                                   c("Black" = "k",
                                     "Brown" = "n",
                                     "Buff" = "b",
                                     "Chocolate" = "h",
                                     "Green" = "r",
                                     "Orange" = "o",
                                     "Purple" = "u",
                                     "White" = "w",
                                     "Yellow" = "y")),
                       p("To take a spore print of your mushroom, place your mushroom gill-side down on a piece of paper (remove the stem). Slightly moisten the top of the mushroom cap. After a while, you should be able to make out the spore print color.")
                 #End Column
                 )
              #End Fluid Row
              ),
              
              hr(style = "border-top: 1px solid #000000;"),
              
              fluidRow(
                column(class =  "column_w_bar", width = 4,
                       
                       p(strong("Summary"), align = "left", style = ("font-size:16px")),
                       
                       tags$head(tags$style(" #output * {display: inline;}")),
                       div(id="output",p(strong("Cap Shape: ")), textOutput("cap_shape_check")),
                       div(id="output",p(strong("Cap Surface: ")), textOutput("cap_surface_check")),
                       div(id="output",p(strong("Cap Color: ")), textOutput("cap_color_check")),
                       
                       hr(),
                       
                       div(id="output",p(strong("Gill Attachment: ")), textOutput("gill_attachment_check")),
                       div(id="output",p(strong("Gill Spacing: ")), textOutput("gill_spacing_check")),
                       div(id="output",p(strong("Gill Size: ")), textOutput("gill_size_check")),
                       div(id="output",p(strong("Gill Color: ")), textOutput("gill_color_check")),
                       
                       hr(),
                       
                       div(id="output",p(strong("Odor: ")), textOutput("odor_check")),
                       div(id="output",p(strong("Spore Print Color: ")), textOutput("spore_print_color_check")),
                        
                  #End Column
                  ),
                 
                 column(class =  "column_w_bar", width = 4,
                        p("Looks like a great mushroom, but should you eat it?"),
                        br(),
                        p(strong("Click on the button below to find out if your mushroom is edible or poisonous.")),
                        br(),
                        actionButton("pred", "Is it poisonous??", icon = icon("skull-crossbones"), style="height:50px; width = 100px;"),
                        br()
                 #End Column
                 ),
                
                column(class =  "column_w_bar", width = 4,
                       p(strong("Results"), align = "left", style = ("font-size:16px")),
                       tags$head(tags$style(" #output * {display: inline;}")),
                       div(id="output",textOutput("pre_text"), htmlOutput("predicted_edibility")),
                       textOutput("tag"),
                       br(),
                       tags$em(textOutput("fact"))
                #End Column
                )
            #End Fluid Row
            ),
            hr(style = "border-top: 1px solid #000000;"),
            
            fluidRow(
              column(class =  "column_w_bar", width = 12,
                     p("Images sourced from ", span(a(href = "https://biolwww.usask.ca/fungi/glossary.html", "Fungi of Saskatchewan Glossary of Terms")), " (University of Saskatchewan)", align = "left", style = ("font-size:12px"))
              #End Column
              )
            #End Fluid Row
            ),
            
            hr()
            
      #End Tab Panel
      ),
      
      tabPanel("Species Classifier",
               hr(style = "border-top: 1px solid #000000;"),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 4
              
                 #End Column    
                 )
                #End Fluid Row
                ),
               
               fluidRow(
                column(class =  "column_w_bar", width = 6,
                       p(strong("Instructions"), align = "left", style = ("font-size:18px")),
                       p("Using the sliding scale to the right, select the number of clusters (or species) to group the mushroom specimens. Then, look at the cluster plot and bar plot underneath. The purer the bars (bars should either be completely red or completely green), the better the classification.")
                #End Column  
                ),
               
                column(class =  "column_w_bar", width = 6,
                       sliderInput("k_clusters", "Number of clusters (species):",
                                   min = 2,
                                   max = 50,
                                   value = 5)
                #End Column 
                )
               #End Fluid Row
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        plotOutput("cluster_plot")
                 #End Column  
                 )
                 
               #End Fluid Row 
               ),
               
               fluidRow(
                 column(class =  "column_w_bar", width = 12,
                        plotOutput("cluster_bars")
                 #End Column        
                 )
               #End Fluid Row 
               )
      #End Tab Panel  
      )
    #End Tabset Panel
    )
#End Fluid Page
)

server <- function(input, output) {
    filename <- "https://archive.ics.uci.edu/ml/machine-learning-databases/mushroom/agaricus-lepiota.data"
    mushrooms <- read.csv(filename, stringsAsFactors = TRUE, col.names = c("edibility", "cap.shape", "cap.surface", "cap.color", "bruises", "odor", "gill.attachment", "gill.spacing", "gill.size", "gill.color", "stalk.shape", "stalk.root", "stalk.surface.above.ring", "stalk.surface.below.ring", "stalk.color.above.ring", "stalk.color.below.ring", "veil.type", "veil.color", "ring.number", "ring.type", "spore.print.color", "population", "habitat"))
    
    # Edibility classifier (Random Forest)
    selected_features <- c("edibility","cap.shape", "cap.surface","cap.color", "odor", 
                           "gill.attachment", "gill.spacing", "gill.size", "gill.color", 
                           "spore.print.color")
    
    levels(mushrooms$cap.shape) <- c("b", "c", "x", "f", "k", "s")
    levels(mushrooms$cap.surface) <- c("f", "g", "y", "s")
    levels(mushrooms$cap.color) <- c("n", "b", "c", "g", "r", "p", "u", "e", "w", "y")
    levels(mushrooms$odor) <- c("a", "l", "c", "y", "f", "m", "n", "p", "s")
    levels(mushrooms$gill.attachment) <- c("a", "d", "f", "n")
    levels(mushrooms$gill.spacing) <- c("c", "w", "d")
    levels(mushrooms$gill.size) <- c("b", "n")
    levels(mushrooms$gill.color) <- c("k", "n", "b", "h", "g", "r", "o", "p", "u","e", "w", "y")
    levels(mushrooms$spore.print.color) <- c("k", "n", "b", "h", "g", "r", "o", "u", "w", "y")
    
    dict_cap_shape <- list(b = "Bell",
                           c = "Conical",
                           x = "Convex",
                           f = "Flat",
                           k = "Knobbed",
                           s = "Sunken")
    
    dict_cap_surface <- list(f = "Fibrous",
                             g = "Grooves",
                             y = "Scaly",
                             s = "Smooth")
    
    dict_cap_color <- list(n = "Brown",
                           b = "Buff",
                           c = "Cinnamon",
                           g = "Gray",
                           r = "Green",
                           p = "Pink",
                           u = "Purple",
                           e = "Red",
                           w = "White",
                           y = "Yellow")
    
    dict_odor <- list(a = "Almond",
                      l = "Anise",
                      c = "Creosote",
                      y = "Fishy",
                      f = "Foul",
                      m = "Musty",
                      n = "None",
                      p = "Pungent",
                      s = "Spicy")
    
    dict_gill_attachment <- list(a = "Attached",
                                 d = "Descending",
                                 f = "Free",
                                 n = "Notched")
  
    dict_gill_spacing <- list(c = "Close",
                               w = "Crowded",
                               n = "Narrow")
    
    dict_gill_size <- list(b = "Broad",
                           n = "Narrow")
    
    dict_gill_color <- list(k = "Black",
                            n = "Brown",
                            b = "Buff",
                            h = "Chocolate",
                            g = "Gray",
                            r = "Green",
                            o = "Orange",
                            p = "Pink",
                            u = "Purple",
                            e = "Red",
                            w = "White",
                            y = "Yellow")
    
    dict_spore_print_color <- list(k = "Black",
                                   n = "Brown",
                                   b = "Buff",
                                   h = "Chocolate",
                                   r = "Green",
                                   o = "Orange",
                                   u = "Purple",
                                   w = "White",
                                   y = "Yellow")
    
    output$cap_shape_check <- renderText({dict_cap_shape[[input$cap_shape]]})
    output$cap_surface_check <- renderText({dict_cap_surface[[input$cap_surface]]})
    output$cap_color_check <- renderText({dict_cap_color[[input$cap_color]]})
    output$gill_attachment_check <- renderText({dict_gill_attachment[[input$gill_attachment]]})
    output$gill_spacing_check <- renderText({dict_gill_spacing[[input$gill_spacing]]})
    output$gill_size_check <- renderText({dict_gill_size[[input$gill_size]]})
    output$gill_color_check <- renderText({dict_gill_color[[input$gill_color]]})
    output$odor_check <- renderText({dict_odor[[input$odor]]})
    output$spore_print_color_check <- renderText({dict_spore_print_color[[input$spore_print_color]]})
    
    index <- sample(2, nrow(mushrooms), replace = TRUE, prob = c(0.8, 0.2))
    mushrooms_train <- mushrooms[index==1,] %>% select(selected_features)
    mushrooms_test <- mushrooms[index==2,] %>% select(selected_features)
    
    rf_model <- randomForest(edibility~., data = mushrooms_train, ntree = 100)
    
    output$rf_plot <- renderPlot({plot(rf_model, main = "Random Forest Model (Error Plot)")
      legend("topright", colnames(rf_model$err.rate), legend=c("OOB", "Edible", "Poisonous"), col = 1:4, cex = 0.8, lty = 1:4)
      })
    
    output$rf_summary <- renderPrint({rf_model})
    
    predictions <- predict(rf_model, newdata = mushrooms_test[-1])
    output$test_set_cf <- renderTable({table(mushrooms_test[,1], predictions) %>% as.data.frame() %>% pivot_wider(names_from = predictions, values_from = Freq) %>% rename(Edible_Actual = e, Poisonous_Actual = p) %>% select(Edible_Actual, Poisonous_Actual) %>% mutate(Edibility = c("Edible_Predicted", "Poisonous_Predicted"), .before = Edible_Actual)})

    observeEvent(input$pred, {
      
      predict_input <- data.frame(
          cap.shape = input$cap_shape,
          cap.surface = input$cap_surface,
          cap.color =input$cap_color,
          odor = input$odor,
          gill.attachment = input$gill_attachment,
          gill.spacing = input$gill_spacing,
          gill.size = input$gill_size,
          gill.color = input$gill_color,
          spore.print.color = input$spore_print_color)
      
      mushrooms_test <- rbind(mushrooms_test[,-1], predict_input)
      
      edible <- predict(rf_model, newdata = mushrooms_test[nrow(mushrooms_test),]) %>% as.character()
      
      output$pre_text <- renderText({"Your mushroom is "})
      if (edible == "e") {
        output$predicted_edibility <- renderText({paste0("<font color=\'#238b45\'><b>", "EDIBLE", "</b></font>", ".")})
        output$tag <- renderText({"Share and enjoy!"})
        output$fact <- renderText({"Mushrooms are more than just food for video game characters. They've been an essential part of South American, Asian, and European cuisine for generations. The earlier known evidence of humans consuming mushrooms dates back to over 5,000 years ago."})
        output$color <- renderText({"green"})
      }
      else{
        output$predicted_edibility <- renderText({paste0("<font color=\'#cb181d\'><b>", "POISONOUS", "</b></font>", ".")})
        output$tag <- renderText({"Look but don't taste!"})
        output$fact <- renderText({"Deadly mushroom poisonings are rare, but they do happen. Notable people who've died after eating poisonous mushrooms include the Roman Emperor Claudius, Pope Clement VII, and the parents of Daniel Fahrenheit."})
        output$color <- renderText({"red"})
      }
    
    #End Observe Event
    })
    
    # K-Means Clustering
    mushrooms_clustered <- mushrooms %>% filter(stalk.root != "?") %>% dummy_cols(., remove_selected_columns = TRUE)
    for (col in colnames(mushrooms_clustered)){
      if ((mean(mushrooms_clustered[[col]]) == 0) || (mean(mushrooms_clustered[[col]]) == 1)) {
        mushrooms_clustered %<>% select(-c(col))
      }
    }

    output$cluster_plot <- renderPlot({
      kmeans_mushrooms <- kmeans(mushrooms_clustered, input$k_clusters, iter.max = 100)
      pca_mushrooms <- prcomp(mushrooms_clustered)
      cluster_plot_data <- data.frame(cluster = as.factor(kmeans_mushrooms$cluster), pc1 = pca_mushrooms$x[,1], pc2 = pca_mushrooms$x[,2], edibility = mushrooms %>% filter(stalk.root != "?") %>% select(edibility))
      
      ggplot(cluster_plot_data, aes(x = pc1, y = pc2, color = cluster, shape = edibility)) + geom_point() + theme_bw() + labs(color = "Cluster", shape = "Edibility") + scale_shape_manual(labels = c("Edible", "Poisonous"), values = c(16, 4)) + xlab("PC1") + ylab("PC2") + ggtitle(paste0("K-Means Clustering Results, K = ", input$k_clusters))
    })
    
    output$cluster_plot_2 <- renderPlot({
      kmeans_mushrooms <- kmeans(mushrooms_clustered, input$k_clusters, iter.max = 100)
      pca_mushrooms <- prcomp(mushrooms_clustered)
      cluster_plot_data <- data.frame(cluster = as.factor(kmeans_mushrooms$cluster), pc1 = pca_mushrooms$x[,1], pc2 = pca_mushrooms$x[,2], edibility = mushrooms %>% filter(stalk.root != "?") %>% select(edibility))
      
      ggplot(cluster_plot_data, aes(x = pc1, y = pc2, color = cluster, shape = edibility)) + geom_point() + theme_bw() + labs(color = "Cluster", shape = "Edibility") + scale_shape_manual(labels = c("Edible", "Poisonous"), values = c(16, 4)) + xlab("PC1") + ylab("PC2") + ggtitle(paste0("K-Means Clustering Results, K = ", input$k_clusters))
    })
    
    output$cluster_bars <- renderPlot({
      kmeans_mushrooms <- kmeans(mushrooms_clustered, input$k_clusters, iter.max = 100)
      pca_mushrooms <- prcomp(mushrooms_clustered)
      cluster_plot_data <- data.frame(cluster = as.factor(kmeans_mushrooms$cluster), pc1 = pca_mushrooms$x[,1], pc2 = pca_mushrooms$x[,2], edibility = mushrooms %>% filter(stalk.root != "?") %>% select(edibility))
      
      cluster_plot_data %>% group_by(cluster, edibility) %>% tally() %>% ggplot(.,aes(fill = edibility, x = cluster, y = n)) + geom_bar(position = "fill", stat = "identity") + theme_bw() + ggtitle(paste0("Distribution of Edibility Across Clusters (Species)")) + xlab("Cluster") + ylab("") + scale_fill_manual(labels = c("Edible", "Poisonous"), values = c("#238b45", "#cb181d")) + labs(fill = "Edibility")
    })
    
    output$cluster_bars_2 <- renderPlot({
      kmeans_mushrooms <- kmeans(mushrooms_clustered, input$k_clusters, iter.max = 100)
      pca_mushrooms <- prcomp(mushrooms_clustered)
      cluster_plot_data <- data.frame(cluster = as.factor(kmeans_mushrooms$cluster), pc1 = pca_mushrooms$x[,1], pc2 = pca_mushrooms$x[,2], edibility = mushrooms %>% filter(stalk.root != "?") %>% select(edibility))
      
      cluster_plot_data %>% group_by(cluster, edibility) %>% tally() %>% ggplot(.,aes(fill = edibility, x = cluster, y = n)) + geom_bar(position = "fill", stat = "identity") + theme_bw() + ggtitle(paste0("Distribution of Edibility Across Clusters (Species)")) + xlab("Cluster") + ylab("") + scale_fill_manual(labels = c("Edible", "Poisonous"), values = c("#238b45", "#cb181d")) + labs(fill = "Edibility")
    })
    
}

shinyApp(ui = ui, server = server)
