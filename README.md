# TokenHider

This is an end to end encryption practice project, the focus was on learning how end to end encryption works with Apple CryptoKit.

Application simulates end to end encryption by implementing a login code that is stored on the device, and assigns individual secrets to each piece of stored data to keep them extra secure. The secrets are never stored on the device, and instead are attached to the end of each stored password as salt, to provide extra security. This also allows for a user to have different secrets for different passwords, and any passwords that do not match the secret will not be shown. 
