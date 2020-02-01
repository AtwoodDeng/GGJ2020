using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CellVisual : MonoBehaviour
{
    public enum CellState
    {
        None,
        Jiankang,
        Kangti,
        Bingdu, 
        Ganran,
        Siwang,
        
    }

    [System.Serializable]
    public struct ColorData
    {
        public CellState state;
        public Color CellColor;
        public Color CoreColor;
        public Texture cellTex;
        public Texture coreTex;
    }

    [Header("====== State ======")]
    public CellState m_state;

    [Header("==== Reference =====")]
    public UnityJellySprite jellySprite;
    public SpriteRenderer core;

    [Header("====== Data ======")]
    public float forceAngleSpeed = 600f;
    public float forceIntensity = 0.5f;
    public float forceOffset = 0.5f;
    public float perlinScale = 0.05f;
    public Vector3[] referencePointsPos;

    [Header("====== Color ======")]
    public List<ColorData> colorDataList;
    public float fadeDuration = 0.5f;

    [Header("====== Material Prefab ======")]
    public Material cellMaterial;
    public Material coreMateral;

    [Header("====== Effect ======")]
    public ParticleSystem HealEffect;
    public ParticleSystem DeadEffect;

    public void InitPos()
    {
        referencePointsPos = new Vector3[jellySprite.ReferencePoints.Count];

		for (int i = 0; i < referencePointsPos.Length; ++i)
		{
			referencePointsPos[i] = jellySprite.ReferencePoints[i].transform.position;

            float offsetAngle = Mathf.PerlinNoise(referencePointsPos[i].x , referencePointsPos[i].y ) * Mathf.PI * 2f  ;


            referencePointsPos[i] += new Vector3( Mathf.Sin(offsetAngle) , Mathf.Cos(offsetAngle) , 0) * forceIntensity * 0.33f;

            jellySprite.ReferencePoints[i].transform.position = referencePointsPos[i];

			jellySprite.ReferencePoints[i].Body2D.simulated = false;

		}

        var cellMat = jellySprite.GetComponent<Renderer>().sharedMaterial;
        cellMat.SetFloat("_BreathOffset", Random.Range(0, 100f));

        var coreMat = Instantiate(coreMateral) as Material;
        core.GetComponent<Renderer>().sharedMaterial = coreMat;
        coreMat.SetFloat("_BreathOffset", Random.Range(0, 100f));

    }

    public void UpdateFloating()
    {
        if (jellySprite.ReferencePoints != null)
        {
            if (referencePointsPos == null || referencePointsPos.Length < 1)
            {
                InitPos();
            }

            for (int i = 0; i < jellySprite.ReferencePoints.Count; i++)
            {
                {
                    var pos = jellySprite.ReferencePoints[i].transform.position;
                    float angle = (Mathf.PerlinNoise(pos.x * perlinScale + Time.time * forceOffset, pos.y * perlinScale + Time.time * forceOffset) * forceAngleSpeed) * Mathf.Deg2Rad;
                    //jellySprite.ReferencePoints[i].Body2D.AddForce(new Vector2(Mathf.Sin(angle), Mathf.Cos(angle)) * forceIntensity );

                    jellySprite.ReferencePoints[i].transform.position = new Vector3(Mathf.Sin(angle), Mathf.Cos(angle), 0) * forceIntensity * ( m_state ==  CellState.Siwang? 0 : 1f )
                        + referencePointsPos[i];
                }

            }
        }

    }

    public void Update()
    {
        UpdateFloating();
    }

    public void SetStateTo( CellState state )
    {
        if ( m_state != state )
        {

            var fastDuration = fadeDuration;
            var slowDuration = fadeDuration * 4f;

            var temColorData = colorDataList.Find((x) => x.state == m_state);
            var colorData = colorDataList.Find((x) => x.state == state);

            var cellMat = jellySprite.GetComponent<Renderer>().sharedMaterial;

            cellMat.SetTexture("_FirstMainTex", temColorData.cellTex);
            cellMat.SetTexture("_SecMainTex", colorData.cellTex);
            DOTween.To(() => cellMat.color, (x) => cellMat.color = x, colorData.CellColor, fadeDuration);

            DOTween.To(() => cellMat.GetFloat("_InfectRate"), (x) => cellMat.SetFloat("_InfectRate",x), state == CellState.Ganran? 0.8f : 0, fadeDuration);
            DOTween.To(() => cellMat.GetFloat("_VirusRate"), (x) => cellMat.SetFloat("_VirusRate", x), state == CellState.Bingdu ? 0.9f : 0, fadeDuration);
            DOTween.To(() => cellMat.GetFloat("_HealRate"), (x) => cellMat.SetFloat("_HealRate", x), state == CellState.Kangti ? 0.9f : 0, fadeDuration);
            DOTween.To((x) => cellMat.SetFloat("_FadeRate", x), 0 , 1f , fadeDuration);

            var coreMat = core.GetComponent<Renderer>().sharedMaterial;
            coreMat.SetTexture("_FirstMainTex", temColorData.coreTex );
            coreMat.SetTexture("_SecMainTex", colorData.coreTex);
            DOTween.To(() => coreMat.color, (x) => coreMat.color = x, colorData.CoreColor, slowDuration);

            DOTween.To(() => coreMat.GetFloat("_InfectRate"), (x) => coreMat.SetFloat("_InfectRate", x), state == CellState.Ganran? 0.94f : 0 , slowDuration);
            DOTween.To(() => coreMat.GetFloat("_VirusRate"), (x) => coreMat.SetFloat("_VirusRate", x), state == CellState.Bingdu ? 0.94f : 0, slowDuration);
            DOTween.To(() => coreMat.GetFloat("_HealRate"), (x) => coreMat.SetFloat("_HealRate", x), state == CellState.Kangti ? 0.95f : 0, slowDuration);

            DOTween.To((x) => coreMat.SetFloat("_FadeRate", x), 0, 1f, slowDuration);

            if ( state == CellState.Kangti )
            {
                HealEffect.Play();
                DOTween.To(() => forceAngleSpeed, (x) => forceAngleSpeed = x, forceAngleSpeed * 5f, slowDuration).From();
                DOTween.To(() => forceIntensity, (x) => forceIntensity = x, forceIntensity * 5f, slowDuration).From();

            }

            if ( state == CellState.Siwang )
            {
                DeadEffect.Play();
            }
        }

        m_state = state;
    }
}
