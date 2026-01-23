echo "Setting up conda environments for short read quality control and multiqc"
# initialize conda for this script
eval "$(conda shell.bash hook)"

# remove previous conda environment if exists
conda env remove -n 01_short_read_qc -y
conda env remove -n 02_multiqc -y

# 01_fastqc and fastp
conda create -n 01_short_read_qc -y 
conda activate 01_short_read_qc
#for quality check
conda install bioconda::fastqc -y
#for quality check and trimming
conda install bioconda::fastp -y

echo "--------------------------------"

echo "Setting up conda environment for multiqc"
#multiqc
conda install bioconda::multiqc
#error because multiqc must be in different environment 
conda create -n 02_multiqc -y
conda activate 02_multiqc 
conda install bioconda::multiqc -y

# genome annotation
echo "Setting up conda environment for genome annotation using Prokka and Bakta"
conda env remove -n 05_genome_annotation -y
conda create -n 05_genome_annotation -c bioconda -c conda-forge prokka bakta -y
conda activate 05_genome_annotation
# check installation
prokka --version
# check prokka databases
prokka --listdb
bakta --version
echo "--------------------------------------------"
## bakta databse download
# bakta_db download --output /home/codanics/databases_important/bakta_db --type light
## manual way will end with 4GB
mkdir -p /home/codanics/databases_important/bakta_db
wget https://zenodo.org/records/14916843/files/db-light.tar.xz \
    -O /home/codanics/databases_important/bakta_db_light.tar.xz
tar -xJvf /home/codanics/databases_important/bakta_db_light.tar.xz \
    -C /home/codanics/databases_important/bakta_db
rm /home/codanics/databases_important/bakta_db_light.tar.xz
# set BAKTA_DB_PATH environment variable
export BAKTA_DB="/home/codanics/databases_important/bakta_db/db-light"
# update amrfinderplus database if needed
amrfinder_update --force_update --database /home/codanics/databases_important/bakta_db/db-light/amrfinderplus-db
echo "--------------------------------------------"
