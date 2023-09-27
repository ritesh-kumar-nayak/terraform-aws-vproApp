resource "aws_key_pair" "Vprofile-key" {

    key_name = "VproProfile-Key-Terra"
    public_key = file(var.PUBLIC_KEY_PATH) #key has been created using ssh-keygen and path has been stored in variable file
  
}
