# install.packages('ggplot')
library(ggplot2)
#fix the theme for the plots
my_theme <- theme( 
  # legend.position='none',
  plot.title = element_text(color="black", 
                            size=12, 
                            face="bold.italic"),
  plot.subtitle = element_text(color="black", 
                            size=10, 
                            face="italic"),
  axis.title.x = element_text(size = 10, face = 'bold'), 
  axis.title.y = element_text(size=10, face="bold"),
  axis.text.x = element_text(size=8, face = 'bold'),
  axis.text.y = element_text(size=8, face = 'bold'),
) 
