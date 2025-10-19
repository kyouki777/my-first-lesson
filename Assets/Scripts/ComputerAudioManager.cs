using System;
using UnityEngine;

[System.Serializable]
public struct SoundParameters
{
    [Range(0f, 1f)] public float Volume;
    [Range(-3f, 3f)] public float Pitch;
    public bool Loop;
}

[System.Serializable]
public class Sound
{
    [SerializeField] private string name = string.Empty;
    public string Name => name;

    [SerializeField] private AudioClip clip = null;
    public AudioClip Clip => clip;

    [SerializeField] private SoundParameters parameters;
    public SoundParameters Parameters => parameters;

    [HideInInspector] public AudioSource Source = null;

    public void Play()
    {
        if (Source == null || Clip == null) return;

        Source.clip = Clip;
        Source.volume = Parameters.Volume;
        Source.pitch = Parameters.Pitch;
        Source.loop = Parameters.Loop;

        Source.Play();
    }

    public void Stop()
    {
        if (Source == null) return;
        Source.Stop();
    }
}

public class ComputerAudioManager : MonoBehaviour
{
    public static ComputerAudioManager Instance;

    [Header("Sounds Setup")]
    [SerializeField] private Sound[] sounds = null;
    [SerializeField] private AudioSource sourcePrefab = null;
    [SerializeField] private string startupTrack = string.Empty;

    [Header("UI Reference")]
    [Tooltip("The computer UI GameObject. Sounds will only play when this is active.")]
    [SerializeField] private GameObject computerUI = null;

    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        InitSounds();
    }

    private void Start()
    {
        if (!string.IsNullOrEmpty(startupTrack))
            PlaySound(startupTrack);
    }

    private void InitSounds()
    {
        foreach (var sound in sounds)
        {
            if (sourcePrefab == null)
            {
                Debug.LogError("[ComputerAudioManager] Source prefab not assigned!");
                continue;
            }

            AudioSource source = Instantiate(sourcePrefab, transform);
            source.name = sound.Name;

            sound.Source = source;
        }
    }

    /// <summary>
    /// Checks whether the computer UI is active.
    /// </summary>
    private bool CanPlaySound()
    {
        return computerUI != null && computerUI.activeSelf;
    }

    /// <summary>
    /// Play a sound by name, only if UI is active.
    /// </summary>
    public void PlaySound(string name, bool ignoreUICheck = false)
    {
        if (!ignoreUICheck && !CanPlaySound()) return;

        Sound sound = GetSound(name);
        if (sound != null)
            sound.Play();
        else
            Debug.LogWarning($"[ComputerAudioManager] Sound '{name}' not found!");
    }



    /// <summary>
    /// Stop a sound by name.
    /// </summary>
    public void StopSound(string name)
    {
        Sound sound = GetSound(name);
        if (sound != null)
            sound.Stop();
        else
            Debug.LogWarning($"[ComputerAudioManager] Sound '{name}' not found!");
    }

    /// <summary>
    /// Stop all sounds immediately.
    /// </summary>
    public void StopAllSounds()
    {
        foreach (var sound in sounds)
        {
            sound?.Stop();
        }
    }

    /// <summary>
    /// Helper to get a sound by name.
    /// </summary>
    private Sound GetSound(string name)
    {
        foreach (var s in sounds)
        {
            if (s.Name == name) return s;
        }
        return null;
    }

    /// <summary>
    /// Toggle computer UI and optionally stop all sounds if closing.
    /// </summary>
    public void ToggleUI(bool isOpen)
    {
        if (computerUI != null)
            computerUI.SetActive(isOpen);

        if (!isOpen)
            StopAllSounds();
    }
}
