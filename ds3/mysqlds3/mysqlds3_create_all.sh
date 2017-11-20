# mysqlds3_create_all.sh
# start in ./ds3/mysqlds3
cd build
echo Creating database
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_create_db.sql
echo Creating Indexes
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_create_ind.sql
echo Creating Stored Procedures
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_create_sp.sql
cd ../load/cust
echo Loading Customer Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_cust.sql
cd ../orders
echo Loading Orders Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_orders.sql
echo Loading Orderlines Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_orderlines.sql
echo Loading Customer History Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_cust_hist.sql
cd ../prod
echo Loading Products Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_prod.sql
echo Loading Inventory Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_inv.sql
cd ../membership
echo Loading Membership data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_member.sql
cd ../reviews
echo Loading Reviews data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_reviews.sql
echo Loading Reviews Helpfulness Ratings Data
mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} < mysqlds3_load_review_helpfulness.sql
