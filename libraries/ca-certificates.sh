rm -rf source
mkdir source
cd source

curl -o mozilla.pem https://curl.se/ca/cacert.pem
sudo mkdir -p /usr/local/share/ca-certificates
sudo cp mozilla.pem /usr/local/share/ca-certificates/cacert.pem
sudo mkdir -p /usr/local/etc/ca-certificates
sudo cp mozilla.pem /usr/local/etc/ca-certificates/cert.pem
