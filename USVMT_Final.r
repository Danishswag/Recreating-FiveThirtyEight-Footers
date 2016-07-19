setwd('C:/Users/prebe/OneDrive/Documents/Web/Articles/2016/001-VMT/')

df.vmt <- read.csv(file='USVMT2016.csv')  # Reading in the data  
names(df.vmt) <- c('Year', 'VMT')         # Changing the names

# Reformatting the dates
df.vmt$Year.POSIXct <- as.POSIXct(df.vmt$Year, format = '%m/%d/%y')  


# All the necessary libraries from CRAN
library(ggplot2)  
library(RColorBrewer)  
library(ggthemes)
library(gtable)
library(scales)  
library(grid)

plt.vmt <- ggplot(df.vmt, aes(Year.POSIXct, VMT)) +  
  # Making x-axis look good
  scale_x_datetime(labels = date_format("'%y"), 
                   breaks = date_breaks("2 years")) +
  
  # Making y-axis look OK 
  scale_y_continuous(labels=comma, breaks=seq(2100,3200, by=200)) +
  
  # Creating a dark line at the bottom of the graph
  geom_line(size=1.5, alpha=0.75, color="#c0392b") +
  geom_hline(yintercept=2100, size=0.4, color="black") +
  
  # Labeling the axes in case you want to use the last line
  ylab('VMT (Billion Miles)') +
  
  # Adding the title
  labs(title='U.S. Annualized VMT over Time') +
  
  # From ggthemes, making it look like 538 
  scale_color_fivethirtyeight(df.vmt) + theme_fivethirtyeight() +
  
  # adding the y-axis labels
  theme(axis.title = element_text()) + 
  theme(axis.title.x = element_blank()) +
  theme(axis.title.y = element_text(size=10, margin=margin(0,15,0,0)))

# The following function is entirely from hrbrmstr's blog post
# at http://www.r-bloggers.com/ggplot2%E3%81%A7%E5%AD%97%E5%B9%95-subtitles-in-ggplot2/
# It now returns a gt object though
ggplot_with_subtitle <- function(gg, 
                                 label="", 
                                 fontfamily=NULL,
                                 color='#656565',
                                 fontsize=10,
                                 hjust=0, vjust=0, 
                                 bottom_margin=5.5,
                                 newpage=is.null(vp),
                                 vp=NULL,
                                 ...) {
  
  if (is.null(fontfamily)) {
    gpr <- gpar(fontsize=fontsize, color=color, ...)
  } else {
    gpr <- gpar(fontfamily=fontfamily, fontsize=fontsize, color=color, ...)
  }
  
  subtitle <- textGrob(label, x=unit(hjust, "npc"), y=unit(hjust, "npc"), 
                       hjust=hjust, vjust=vjust,
                       gp=gpr)
  
  data <- ggplot_build(gg)
  
  gt <- ggplot_gtable(data)
  gt <- gtable_add_rows(gt, grobHeight(subtitle), 2)
  gt <- gtable_add_grob(gt, subtitle, 3, 4, 3, 4, 8, "off", "subtitle")
  gt <- gtable_add_rows(gt, grid::unit(bottom_margin, "pt"), 3)
  
  if (newpage) grid.newpage()
  
  if (is.null(vp)) {
    grid.draw(gt)
  } else {
    if (is.character(vp)) seekViewport(vp) else pushViewport(vp)
    grid.draw(gt)
    upViewport()
  }
  
  invisible(data)
  return(gt)
}


# Adding in the subtitle
subtitle <- 'Annualized Vehicle Miles Travelled Over Time'
plt.vmt_sub <- ggplot_with_subtitle(plt.vmt, subtitle, '', 14, color='#656565')

# Adding in the footer
grid.newpage() # Resetting the page

# Blog name
text.Name <- textGrob('  justjensen.co', x=unit(0, 'npc'), 
                      gp=gpar(col='white', family='sans', fontsize=8), 
                      hjust=0)

# Source Name
text.Source <- textGrob('Source: U.S. Department of Transportation  ', 
                        x=unit(1, 'npc'), gp=gpar(col='white', family='',
                                                  fontsize=8),
                        hjust=1)

# Making the whole footer
footer = grobTree(rectGrob(gp=gpar(fill='#5B5E5F', lwd=0)), text.Name, 
                  text.Source)

# Final plot! I saved mine as an SVG using 575x350 as dimensions
plt.final <- grid.arrange(plt.vmt_sub, footer, heights=unit(c(0.94, 0.06), 
                                                            c('npc', 'npc')))
