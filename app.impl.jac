:can:get_pdf_text(files:list){
    text = "";
    for file in files{
        pdf = PdfReader(file);
        for page in pdf.pages{
            text += page.extract_text();
            }
    }
    return text;
}


:can:get_junk_text(text: str){
    test_splitter = CharacterTextSplitter(separator="\n",
                                          chunk_size=1000,
                                          chunk_overlap=200,
                                          length_function=len);
    chunks = test_splitter.split_text(text);
    return chunks;
}


:can:get_vector_store(text_chunks: any){
    embeddings = OpenAIEmbeddings();
    # embeddings = HuggingFaceEmbeddings(model_name="hkunlp/instructor-xl");
    vectorstore = FAISS.from_texts(texts=text_chunks, embedding=embeddings);
    return vectorstore;
}


:can:get_conversation(vectorstore: any){
    llm = ChatOpenAI();
    memory = ConversationBufferMemory(memory_key='chat_history', return_messages=True);
    chain = ConversationalRetrievalChain.from_llm(llm=llm,
        retriever=vectorstore.as_retriever(),
        memory=memory);
    return chain;
}


:can:handle_user_input(user_input: any, conversation: any){
    response = conversation({'question':user_input});
    st.session_state.chat_history = response['chat_history'];

    for (i , message) in enumerate(st.session_state.chat_history){
        if i % 2 == 0{
            st.write(user_template.replace("{{MSG}}", message.content), unsafe_allow_html=True);
            }
        else{
            st.write(bot_template.replace("{{MSG}}", message.content), unsafe_allow_html=True);
            }
    }
}