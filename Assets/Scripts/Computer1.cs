using UnityEngine;

public class Computer1 : MonoBehaviour
{
    public GameObject uiPanel; // assign in Inspector
    private bool playerInZone = false;

    void Update()
    {
        if (playerInZone && Input.GetKeyDown(KeyCode.E))
        {
            // Toggle the UI panel
            uiPanel.SetActive(!uiPanel.activeSelf);
            Debug.Log("Toggled UI!");

            // Play or stop audio depending on UI state
            if (uiPanel.activeSelf)
            {
                // Play the computer UI sound
                ComputerAudioManager.Instance.PlaySound("ComputerSound");
                //ComputerAudioManager.Instance.PlaySound("CorrectSFX");
                //ComputerAudioManager.Instance.PlaySound("IncorrectSFX");

                Debug.Log("Audiomanager running");
            }
            else
            {
                // Stop all sounds or just the UI sound
                ComputerAudioManager.Instance.StopSound("ComputerSound");
                //ComputerAudioManager.Instance.StopSound("CorrectSFX");
                //ComputerAudioManager.Instance.StopSound("IncorrectSFX");
            }
        }
    }


    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = true;
            Debug.Log("Player entered zone");
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = false;
            uiPanel.SetActive(false);
            Debug.Log("Player left zone");
        }
    }
}


