using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProceduralGeometrySilhouettingHelper : MonoBehaviour {
    public enum NormalType {
        Object,
        View,
        World
    };

    public NormalType nt;

    Renderer r;

    void Start() {
        r = GetComponent<Renderer>();
        r.material.SetInt("_NormalType", (int)nt);
    }

    void Update() {
        r.material.SetInt("_NormalType", (int)nt);
    }
}
