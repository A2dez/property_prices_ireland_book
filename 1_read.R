
library(readr)
library(purrr)
library(magrittr)
library(dplyr)


read_property_prices <- 
  function(property_data_url = "https://www.propertypriceregister.ie/website/npsra/ppr/npsra-ppr.nsf/Downloads", 
           property_rds_filepath = './data/property_raw_all_years_except_this_one.rds', 
           first_year = 2010){
    
        data_folder = file.path('.', "data")
        if (!dir.exists(data_folder)){dir.create(data_folder)} 
        # else {print("Data directory already exists!")}
        
        
        # Extract years up to today
        current_year = as.numeric(format(Sys.Date(),"%Y"))
        relevant_years = first_year:current_year
        #templated version of the url containing CSVs for each year
        url_csv_addresses = file.path(property_data_url, 
                                      paste0('PPR-',relevant_years, '.csv'), 
                                      '$FILE', 
                                      paste0('PPR-', relevant_years, '.csv')
                                      )
        
        
        # -------------------------------------------------------------------------
        #Read in data until the end of last year, if we have it already
        if (file.exists(property_rds_filepath)) {
          property_raw_until_last_year <- readRDS(property_rds_filepath)
          # print(paste('Reading data from',  property_rds_filepath))
        } else {
          addresses = url_csv_addresses[1:(length(url_csv_addresses)-1)]
          # print('Reading data from:')
          # print(addresses)
          property_raw_until_last_year <- 
            #take all years but this one
            addresses %>% 
            #and apply function to the url for each year. 
            purrr::map_dfr(  ~  read_csv(.x, 
                                         col_types = "ccccccccc", 
                                         locale=locale(encoding="latin1"),
                                         progress = show_progress()
            )
            )
          
          saveRDS(property_raw_until_last_year, './data/property_raw_all_years_except_this_one.rds')
  }
  
  #this should be reading the url
        address <- url_csv_addresses[length(url_csv_addresses)]
        # print(paste('Reading data from ', address))
  property_raw_this_year <- 
     address %>% 
    #apply function to the url for each year. 
    purrr::map_dfr(  ~  read_csv(.x, 
                                 col_types = "ccccccccc", 
                                 locale=locale(encoding="latin1"),
                                 progress = show_progress()))
  
  
  property_raw <- bind_rows(property_raw_until_last_year, property_raw_this_year)
  return (property_raw)
}


# names(property_raw)
# [1] "Date of Sale (dd/mm/yyyy)" "Address"                   "County"                    "Eircode"                   "Price (\u0080)"           
# [6] "Not Full Market Price"     "VAT Exclusive"             "Description of Property"   "Property Size Description"
# View(property_raw)


# -------------------------------------------------------------------------

read_postcode_data <- function(postcodes_dfrm_path, postcode_data_path ){
  if (file.exists(postcodes_dfrm_path)){
    postcodes_dfrm <- readRDS(postcodes_dfrm_path)
  } else if(file.exists(postcode_data_path)){
    # print('Reading in and saving data from 2010 - May 2021, containing')
    postcodes_dfrm <- read_csv(postcode_data_path, 
                               locale=locale(encoding="latin1")) %>% 
      select('SALE_DATE', 'ADDRESS', 'POSTAL_CODE') %>% 
      filter(!is.na(POSTAL_CODE)) 
    saveRDS(postcodes_dfrm, 'postcodes.rds')
  } else {
    # print('No postcode data found')
    postcodes_dfrm <- NULL
  }
  
  return(postcodes_dfrm)
}


# names(property_2010_2021_with_postcodes)
# [1] "SALE_DATE"          "ADDRESS"            "POSTAL_CODE"        "COUNTY"             "SALE_PRICE"         "IF_MARKET_PRICE"   
# [7] "IF_VAT_EXCLUDED"    "PROPERTY_DESC"      "PROPERTY_SIZE_DESC"

#n.b. we don't need dates cos the postcode won't have changed. 
# property_2010_2021_with_postcodes 

  # mutate(available = ADDRESS %in% property_raw$Address)

#The few cases where the addressed differ are due to fadas:
#.e.g. 87 Bï¿½thar an Bhreatnaigh, Droim Conrach, B.ï¿½.C 3
# table(postcodes_dfrm$available)
# FALSE  TRUE 
# 62 89702 
